#!/bin/bash

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# Ensure the script stops on errors
set -e

# Install Docker
if ! command -v docker &> /dev/null
then
    msg_info "Installing Docker..."
    curl -fsSL https://get.docker.com | sh > /dev/null 2>&1
    msg_ok "Docker installed"
fi

# Install required dependencies for Node.js
msg_info "Installing required dependencies..."
apt install -y curl ca-certificates gnupg > /dev/null 2>&1
msg_ok "Installed required dependencies"

# Add NodeSource repository for Node.js LTS


# Install Node.js and npm
msg_info "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &>/dev/null
apt install -y nodejs > /dev/null 2>&1
msg_ok "Node.js version $(node -v) installed"

# Install latest version of npm
msg_info "Installing latest version of NPM..."
npm install -g npm > /dev/null 2>&1
msg_ok "NPM version $(npm -v) installed"

# Install Dev Containers CLI globally
msg_info "Installing @devcontainers/cli..."
npm install -g @devcontainers/cli > /dev/null 2>&1
msg_ok "Installed devcontainers CLI version: $(devcontainer --version)"


# Install code-server
curl -fsSL https://code-server.dev/install.sh | sh

# Define config path
CONFIG_FILE="$HOME/.config/code-server/config.yaml"

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$CONFIG_FILE")"

# Set up config with LAN access on port 8080 and no auth
cat > "$CONFIG_FILE" <<EOF
bind-addr: 0.0.0.0:8080
auth: none
cert: false
working-directory: $HOME
EOF

# Enable and restart the code-server systemd service
sudo systemctl enable --now code-server@$USER
sudo systemctl restart code-server@$USER


# Setup docker to auto start on boot
systemctl enable docker
systemctl start docker
usermod -aG docker $USER

SSH_PUBKEY=$(get_input  "Enter your Public SSH key. You can get it by putting in the terminal: cat ~/.ssh/id_ed25519.pub" "Public key" "") || error_exit "Failed to get GitHub repository"
HA_REPOSITORY=$(get_input  "Enter your (forked) Home Assistant Github repository" "GitHub repository" "Getslow6/core") || error_exit "Failed to get Home Assistant forked repository"
CC_REPOSITORY=$(get_input  "Enter your custom component Github repository" "GitHub repository" "Getslow6/monitor_docker") || error_exit "Failed to get Custom Component repository"
CC_FOLDER="${CC_REPOSITORY#*/}" # Cut away everything until the first /

clear

msg_info "Updating SSH configuration"
echo "$SSH_PUBKEY" >> /root/.ssh/authorized_keys
msg_ok "Updated SSH configuration"


msg_info "Cloning Home Assistant Core"
rm -rf /root/home-assistant
git clone --quiet --single-branch --depth 1 https://github.com/${HA_REPOSITORY} /srv/home-assistant || error_exit "Failed cloning the Home Assistant repository"
msg_ok "Cloned Home Assistant Core"

msg_info "Cloning Custom component"
git clone --quiet --single-branch --depth 1 https://github.com/${CC_REPOSITORY} /srv/${CC_FOLDER}|| error_exit "Failed cloning the Custom component repository"
msg_ok "Cloned Custom component"

msg_info "Updating devcontainer.json with custom component mount"
DEVCONTAINER_JSON="/srv/home-assistant/.devcontainer/devcontainer.json"

# Define the mount to add
NEW_MOUNT="source=/srv/${CC_FOLDER}/custom_components,target=\${containerWorkspaceFolder}/config/custom_components,type=bind"

# Strip comments and write to temp file
# This removes lines that start with optional whitespace and then `//`
TMP_JSON=$(mktemp)
grep -v '^\s*//' "$DEVCONTAINER_JSON" > "$TMP_JSON"

# Check if "mounts" exists
if jq 'has("mounts")' "$TMP_JSON" | grep -q true; then
  jq --arg newMount "$NEW_MOUNT" \
     '.mounts |= if index($newMount) then . else . + [$newMount] end' "$TMP_JSON" > "$TMP_JSON.tmp"
else
  jq --arg newMount "$NEW_MOUNT" \
     '. + {mounts: [$newMount]}' "$TMP_JSON" > "$TMP_JSON.tmp"
fi

# Ensure remoteUser is set to "root"
if jq 'has("remoteUser")' "$TMP_JSON.tmp" | grep -q true; then
  jq '.remoteUser = "root"' "$TMP_JSON.tmp" > "$TMP_JSON.new"
else
  jq '. + {remoteUser: "root"}' "$TMP_JSON.tmp" > "$TMP_JSON.new"
fi

# Replace original file 
mv "$TMP_JSON.new" "$DEVCONTAINER_JSON"
rm "$TMP_JSON"



msg_info "Adding port 8080 forwarding to devcontainer.json runArgs..."

# Strip comments from JSON
TMP_JSON=$(mktemp)
grep -v '^\s*//' "$DEVCONTAINER_JSON" > "$TMP_JSON"

# Check if runArgs exists
if jq 'has("runArgs")' "$TMP_JSON" | grep -q true; then
  # Check if "-p" "8081:8081" pair already exists
  if jq '.runArgs | index("-p")' "$TMP_JSON" | grep -q null; then
    # No "-p" found, add the pair
    jq '.runArgs += ["-p", "8081:8081"]' "$TMP_JSON" > "$TMP_JSON.tmp"
  else
    # "-p" found, check if "8081:8081" exists right after
    IDX=$(jq '.runArgs | to_entries | map(select(.value == "-p")) | .[0].key' "$TMP_JSON")
    NEXT_VAL=$(jq -r ".runArgs[$((IDX+1))]" "$TMP_JSON")
    if [ "$NEXT_VAL" != "8081:8081" ]; then
      jq '.runArgs += ["-p", "8081:8081"]' "$TMP_JSON" > "$TMP_JSON.tmp"
    else
      cp "$TMP_JSON" "$TMP_JSON.tmp"
    fi
  fi
else
  # runArgs doesn't exist, add it with the port forwarding args
  jq '. + {runArgs: ["-p", "8080:8080"]}' "$TMP_JSON" > "$TMP_JSON.tmp"
fi

mv "$TMP_JSON.tmp" "$DEVCONTAINER_JSON"
rm "$TMP_JSON"

msg_ok "Added port forwarding to devcontainer.json"


msg_ok "Updated devcontainer.json"

msg_info "Update permissions of /srv"
chmod -R a+rw /srv
msg_ok "Updated permissions of /srv"

# Start the devcontainer
devcontainer up --workspace-folder /srv/home-assistant

# Get devcontainer name (latest created container)
DEVCONTAINER_NAME=$(docker ps --format '{{.Names}}' --filter "ancestor=dev_container_autoadded_stage_label" | head -n 1)
if [ -z "$DEVCONTAINER_NAME" ]; then
    # fallback: get container running with workdir mounted
    DEVCONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep home-assistant | head -n 1)
fi

if [ -z "$DEVCONTAINER_NAME" ]; then
    error_exit "Could not find devcontainer container name."
fi
msg_ok "Detected devcontainer: $DEVCONTAINER_NAME"

# Install code-server inside the devcontainer
msg_info "Installing code-server inside devcontainer..."
docker exec -u root "$DEVCONTAINER_NAME" bash -c "curl -fsSL https://code-server.dev/install.sh | sh" > /dev/null 2>&1
msg_ok "code-server installed inside devcontainer"

# Start code-server in background inside devcontainer
msg_info "Starting code-server inside devcontainer..."
docker exec -u root -d "$DEVCONTAINER_NAME" \
  code-server /workspaces/home-assistant \
    --bind-addr 0.0.0.0:8081 \
    --auth none
msg_ok "code-server started on http://<LXC-IP>:8081 (no auth)"


msg_ok "Devcontainer is setup"



