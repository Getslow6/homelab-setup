#!/bin/bash

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# Ensure the script stops on errors
set -e

# Install required dependencies (based on Chat GPT's suggestion)
apt install -y curl git nodejs npm bash unzip gnupg ca-certificates

# Install Docker
curl -fsSL https://get.docker.com | sh

# Setup docker to auto start on boot
systemctl enable docker
systemctl start docker
usermod -aG docker $USER

# Make a config file for code-server
mkdir -p ~/.config/code-server
echo "bind-addr: 0.0.0.0:8080
auth: password
password: $(openssl rand -base64 12)
cert: false" > ~/.config/code-server/config.yaml

# Download and install code-server
curl -fsSL https://code-server.dev/install.sh | sh

GITHUB_REPOSITORY=$(get_input  "Enter your forked Home Assistant repository" "GitHub repository" "Getslow6/core") || error_exit "Failed to get GitHub repository"
git clone "$GITHUB_REPOSITORY" homeassistant-dev
cd homeassistant-dev

systemctl enable --now code-server@$USER
systemctl restart code-server@$USER

echo "Setup complete!"
echo "You can access code-server at http://<your-lxc-ip>:8080"
echo "The password is stored in ~/.config/code-server/config.yaml"
echo "For simplicity, this is the password: $(cat ~/.config/code-server/config.yaml | grep password | cut -d ' ' -f 2)"