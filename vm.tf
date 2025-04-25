data "azurerm_platform_image" "cenTest" {
  location  = azurerm_resource_group.cenTest.location
  publisher = "Debian"
  offer     = "Debian-11"
  sku       = "11"
}

resource "random_password" "password" {
  length = 16
  special = false
}

resource "random_password" "password_geoserver" {
  length = 16
  special = false
}

data "cloudinit_config" "config" {
 gzip = true
 base64_encode = true

  part {
    content = file("${path.module}/scripts/init.yaml")
    content_type = "text/cloud-config"
  }

  part {
    filename = "start.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/start.sh",
      {
        password_postgres = random_password.password.result,
        password_geoserver = random_password.password_geoserver.result,
      }
    )
  }

}

resource "azurerm_resource_group" "cenTest" {
  name     = "cenTest-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "cenTest" {
  name                = "cenTest-network"
  resource_group_name = azurerm_resource_group.cenTest.name
  location            = azurerm_resource_group.cenTest.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cenTest" {
  name = "internal"
  resource_group_name = azurerm_resource_group.cenTest.name
  virtual_network_name = azurerm_virtual_network.cenTest.name
  address_prefixes = [cidrsubnet(tolist(azurerm_virtual_network.cenTest.address_space)[0], 8, 2)]
}

resource "azurerm_public_ip" "cenTest" {
  name                = "cenTest-ip"
  location            = azurerm_resource_group.cenTest.location
  resource_group_name = azurerm_resource_group.cenTest.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "cenTest" {
  name = "cenTest-nic"
  location = azurerm_resource_group.cenTest.location
  resource_group_name = azurerm_resource_group.cenTest.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.cenTest.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.cenTest.id
  }
}

resource "azurerm_network_security_group" "cenTest" {
  name                = "cenTest-nsg"
  location            = azurerm_resource_group.cenTest.location
  resource_group_name = azurerm_resource_group.cenTest.name

  security_rule {
    name                       = "AllowAnySSHInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAnyHTTPInbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "8080"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "cenTest" {
  network_interface_id      = azurerm_network_interface.cenTest.id
  network_security_group_id = azurerm_network_security_group.cenTest.id
}

resource "azurerm_linux_virtual_machine" "cenTest" {
  name = "cenTest-machine"
  resource_group_name = azurerm_resource_group.cenTest.name
  location = azurerm_resource_group.cenTest.location
  size = "Standard_A2_v2"
  admin_username = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.cenTest.id
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/ssh_key.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.cenTest.publisher
    offer = data.azurerm_platform_image.cenTest.offer
    sku = data.azurerm_platform_image.cenTest.sku
    version = data.azurerm_platform_image.cenTest.version
  }
  
  custom_data = data.cloudinit_config.config.rendered
  
}

/*resource "terracurl_request" "cenTest" {
  name = "cenTest"
  url = "http://${resource.azurerm_public_ip.cenTest.ip_address}/init.sh"
  method = "GET"

  response_codes = [200]
  max_retry = 120
  retry_interval = 20
}*/
