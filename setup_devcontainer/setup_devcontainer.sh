#!/bin/bash

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# Ensure the script stops on errors
set -e

# Install Docker
if ! command -v docker &> /dev/null
then
    curl -fsSL https://get.docker.com | sh
fi

# # Install code-server
# curl -fsSL https://code-server.dev/install.sh | sh

# # Define config path
# CONFIG_FILE="$HOME/.config/code-server/config.yaml"

# # Create config directory if it doesn't exist
# mkdir -p "$(dirname "$CONFIG_FILE")"

# # Set up config with LAN access on port 8080 and no auth
# cat > "$CONFIG_FILE" <<EOF
# bind-addr: 0.0.0.0:8080
# auth: none
# cert: false
# working-directory: $HOME
# EOF

# # Enable and restart the code-server systemd service
# sudo systemctl enable --now code-server@$USER
# sudo systemctl restart code-server@$USER


# Setup docker to auto start on boot
systemctl enable docker
systemctl start docker
usermod -aG docker $USER

SSH_PUBKEY=$(get_input  "Enter your Public SSH key. You can get it by putting in the terminal: cat ~/.ssh/id_ed25519.pub" "Public key" "") || error_exit "Failed to get GitHub repository"
GITHUB_REPOSITORY=$(get_input  "Enter your (forked) Home Assistant Github repository" "GitHub repository" "home-assistant/core") || error_exit "Failed to get GitHub repository"
clear

msg_info "Updating SSH configuration"

echo "$SSH_PUBKEY" >> /root/.ssh/authorized_keys

msg_ok "Updated SSH configuration"


msg_info "Cloning Git repository"
rm -rf /root/home-assistant
git clone --quiet --branch dev --single-branch --depth 1 https://github.com/${GITHUB_REPOSITORY} home-assistant || error_exit "Failed cloning the repository"

msg_ok "Cloned Git repository"



