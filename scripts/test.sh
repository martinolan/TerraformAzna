sudo apt update && sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# DOCKER
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# POSTGIS
sudo docker pull postgis/postgis:17-3.5
sudo docker run --name postgis -e POSTGRES_USER=geonature -e POSTGRES_PASSWORD=${password_postgres} -e POSTGRES_DB=geonature_db -d postgres

# SETUP GEONATURE
sudo echo "LANG=fr_FR.UTF-8" | sudo tee -a /etc/default/locale > /dev/null
sudo source /etc/default/locale
sudo update-locale LANG=fr_FR.UTF-8

sudo docker pull docker.osgeo.org/geoserver:2.27.0
sudo docker run -d -p 80:8080 -e GEOSERVER_ADMIN_PASSWORD=${password_geoserver} -e GEOSERVER_ADMIN_USER=admin docker.osgeo.org/geoserver:2.27.0 --name geoserver 

#Create a test file to test the succes of the script
touch /tmp/myfile
echo ${password_postgres} > /tmp/myfile

