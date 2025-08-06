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

# Install required dependencies for Node.js
echo "Installing required dependencies..."
apt install -y curl ca-certificates gnupg

# Add NodeSource repository for Node.js LTS
echo "Adding NodeSource Node.js repository..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -

# Install Node.js and npm
echo "Installing Node.js and npm..."
apt install -y nodejs

# Install latest version of npm
npm install -g npm

# Confirm Node.js and npm versions
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# Install Dev Containers CLI globally
echo "Installing @devcontainers/cli..."
npm install -g @devcontainers/cli

# Confirm installation
echo "Installed devcontainers CLI version: $(devcontainer --version)"

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

# SSH_PUBKEY=$(get_input  "Enter your Public SSH key. You can get it by putting in the terminal: cat ~/.ssh/id_ed25519.pub" "Public key" "") || error_exit "Failed to get GitHub repository"
HA_REPOSITORY=$(get_input  "Enter your (forked) Home Assistant Github repository" "GitHub repository" "home-assistant/core") || error_exit "Failed to get Home Assistant forked repository"
CC_REPOSITORY=$(get_input  "Enter your custom component Github repository" "GitHub repository" "username/custom-component") || error_exit "Failed to get Custom Component repository"
CC_FOLDER="${CC_REPOSITORY#*/}" # Cut away everything until the first /

clear

msg_info "Updating SSH configuration"

echo "$SSH_PUBKEY" >> /root/.ssh/authorized_keys

msg_ok "Updated SSH configuration"


msg_info "Cloning Home Assistant Core"
rm -rf /root/home-assistant
git clone --quiet --single-branch --depth 1 https://github.com/${HA_REPOSITORY} home-assistant || error_exit "Failed cloning the Home Assistant repository"

msg_info "Cloning Custom component"
git clone --quiet --single-branch --depth 1 https://github.com/${CC_REPOSITORY} ${CC_FOLDER}|| error_exit "Failed cloning the Custom component repository"


msg_info "Updating devcontainer.json with custom component mount"

DEVCONTAINER_JSON="/root/home-assistant/.devcontainer/devcontainer.json"

# Define the mount to add
NEW_MOUNT="source=/root/${CC_FOLDER}/custom_components,target=\${containerWorkspaceFolder}/config/custom_components,type=bind"

# Strip comments and write to temp file
# This removes lines that start with optional whitespace and then `//`
TMP_JSON=$(mktemp)
grep -v '^\s*//' "$DEVCONTAINER_JSON" > "$TMP_JSON"

# Check if "mounts" exists
if jq 'has("mounts")' "$TMP_JSON" | grep -q true; then
  jq --arg newMount "$NEW_MOUNT" \
     '.mounts |= if index($newMount) then . else . + [$newMount] end' "$TMP_JSON" > "$TMP_JSON.new"
else
  jq --arg newMount "$NEW_MOUNT" \
     '. + {mounts: [$newMount]}' "$TMP_JSON" > "$TMP_JSON.new"
fi

# Replace original file 
mv "$TMP_JSON.new" "$DEVCONTAINER_JSON"
rm "$TMP_JSON"

# Start the devcontainer
devcontainer up --workspace-folder /root/home-assistant



msg_ok "Cloned Git repository"



