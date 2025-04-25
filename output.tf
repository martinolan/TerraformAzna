output "publicID" {
  value = resource.azurerm_public_ip.cenTest.ip_address
}

output "password_postgres" {
  sensitive = true
  value = random_password.password.result
}

output "password_geoserver" {
  sensitive = true
  value = random_password.password_geoserver.result
}