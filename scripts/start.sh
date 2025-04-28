sudo apt update && sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    postgresql-client

# DOCKER
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# GEOSERVER ?
sudo mkdir -p /opt/geoserver_data
sudo mkdir -p /opt/postgis_data
sudo chmod -R 777 /opt/geoserver_data /opt/postgis_data

sudo git clone https://github.com/geoserver/docker.git /opt/geoserver-docker

sudo sed -i "s/^\(\s*POSTGRES_PASSWORD:\s*\)geoserver/\1${password_postgres}/" /opt/geoserver-docker/docker-compose-demo.yml
sudo sed -i "s/^\(\s*-\s*POSTGRES_PASSWORD=\)geoserver/\1${password_postgres}/" /opt/geoserver-docker/docker-compose-demo.yml
sudo sed -i "s|\(^\s*-\s*\)\./postgis/postgresql_data|\1/opt/postgis_data|g" /opt/geoserver-docker/docker-compose-demo.yml
sudo sed -i "s|\(^\s*-\s*\)\./geoserver_data\(:/opt/geoserver_data/:Z\)|\1/opt/geoserver_data\2|" /opt/geoserver-docker/docker-compose-demo.yml
sudo sed -i "s/^\(\s*POSTGRES_PASSWORD:\s*\)geoserver/\1${password_postgres}/" /opt/geoserver-docker/docker-compose-demo.yml

# GEONATURE
sudo git clone https://github.com/PnX-SI/GeoNature-Docker-services.git /opt/geonature-docker

sudo chmod -R 777 /opt/geonature-docker
sudo cp /opt/geonature-docker/.env.sample /opt/geonature-docker/.env

sudo sed -i 's/^ACME_EMAIL=".*"/ACME_EMAIL="nolan.martin@1004.tech"/' /opt/geonature-docker/.env
sudo sed -i 's/^ACME_EMAIL=".*"/ACME_EMAIL="nolan.martin@1004.tech"/' /opt/geonature-docker/.env
sudo sed -i "s/^POSTGRES_PASSWORD=".*"/POSTGRES_PASSWORD=\"${password_postgres}\"/" /opt/geonature-docker/.env
sudo sed -i 's/^BASE_PROTOCOL=".*"/BASE_PROTOCOL="http"/' /opt/geonature-docker/.env

sudo /opt/geonature-docker/init-config.sh


# START DOCKER
sudo docker compose -f /opt/geonature-docker/docker-compose.yml up -d
sudo docker-compose -f /opt/geoserver-docker/docker-compose-demo.yml up --build


