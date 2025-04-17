# Function to get user input using whiptail
get_input() {
    local prompt="$1"
    local title="$2"
    local default="$3"
    whiptail --backtitle "Homelab setup" --inputbox "\n$prompt" 9 58 "$default" --title "$title" 3>&1 1>&2 2>&3
}

# Function to display error message and exit
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Function to get user input with a password box
get_password() {
    local prompt="$1"
    local title="$2"
    whiptail --backtitle "Homelab setup" --passwordbox "\n$prompt" 9 58 --title "$title" 3>&1 1>&2 2>&3
}

# First install Git on Alpine Linux
apk add git -q

# Get GitHub repository details from the user
GITHUB_REPOSITORY=$(get_input    "Enter your GitHub repository"                     "GitHub repository" "https://github.com/Getslow6/homelab-config") || error_exit "Failed to get GitHub repository"
GITHUB_USER=$(      get_input    "Enter your GitHub username for committing to Git" "Git Username")     "Getslow6" || error_exit "Failed to get GitHub username"
GITHUB_PAT=$(       get_password "Enter your GitHub Personal Access Token (PAT)"    "GitHub PAT")        || error_exit "Failed to get GitHub PAT"

# adduser $USER
# chown $USER: /srv

git config --global credential.helper store
# Make sure that local git uses the already stored credentials
git config --global user.email "$GITHUB_USER@proxmox.local"
git config --global user.name "$GITHUB_USER"

# Clone the github config to the /srv folder
echo "▶️ Cloning Git repository"
git clone --quiet https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_REPOSITORY} /srv
echo "✅ Cloned Git repository"

# Make sure that local git uses the already stored credentials
cd /srv
git config credential.helper store


# Create docker networks that are used
docker network create mqtt
docker network create proxy
docker network create authelia

# Containers to start, in sequence
containers=(
  "traefik"
  "cloudflared-proxmox"
  "dockge"
)

# Loop through each container and bring it up
for container in "${containers[@]}"; do
  compose_file="/srv/applications/$container/docker-compose.yml"

  echo "▶️ Starting Docker Compose for: $container"

  if docker compose -f "$compose_file" up -d; then
    echo "✅ Successfully started: $container"
  else
    echo "❌ Failed to start: $container" >&2
  fi
done

echo "✅ Setup complete"
