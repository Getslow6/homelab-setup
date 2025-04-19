#!/bin/bash

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

sudo apt install -y curl git nodejs npm docker.io docker-compose bash unzip gnupg ca-certificates
sudo systemctl enable docker


# Make a config file for code-server
mkdir -p ~/.config/code-server
echo "bind-addr: 0.0.0.0:8080
auth: password
password: yourpassword
cert: false" > ~/.config/code-server/config.yaml

# Download and install code-server
curl -fsSL https://code-server.dev/install.sh | sh


git clone https://github.com/home-assistant/core.git homeassistant-dev
cd homeassistant-dev


sudo systemctl enable --now code-server@$USER

sudo systemctl restart code-server@$USER
