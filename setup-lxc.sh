
# Load the self defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# First install Git on Alpine Linux
apk add git -q

# Get GitHub repository details from the user
GITHUB_REPOSITORY=$(get_input    "Enter your GitHub repository"                     "GitHub repository" "Getslow6/homelab-config") || error_exit "Failed to get GitHub repository"
GITHUB_USER=$(      get_input    "Enter your GitHub username for committing to Git" "Git Username"      "Getslow6" ) || error_exit "Failed to get GitHub username"
GITHUB_PAT=$(       get_password "Enter your GitHub Personal Access Token (PAT)"    "GitHub PAT")        || error_exit "Failed to get GitHub PAT"

# adduser $USER
# chown $USER: /srv

git config --global credential.helper store
# Make sure that local git uses the already stored credentials
git config --global user.email "$GITHUB_USER@proxmox.local"
git config --global user.name "$GITHUB_USER"

# Clone the github config to the /srv folder
echo "▶️ Cloning Git repository"
git clone --quiet https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_REPOSITORY} /srv || error_exit "Failed cloning the repository"
echo "✅ Cloned Git repository"

# Make sure that local git uses the already stored credentials
cd /srv
git config credential.helper store


# Create docker networks that are used
docker network create mqtt
docker network create proxy
docker network create authelia


# Build the containers list from directories
containerlist=""
for dir in /srv/applications/*; do
  [ -d "$dir" ] && containerlist="$containerlist $(basename "$dir")"
done

containers_on="\
 cloudflared-proxmox\
 traefik\
" 


# Build the options string for whiptail
options=""
for container in $containers; do
  if echo "$containers_on" | grep -qw "$container"; then
    options="$options $container $container ON"
  else
    options="$options $container $container OFF"
  fi
done

# Show the checklist
choices=$(whiptail --title "Select containers to start" \
  --checklist "Choose containers:" 20 60 10 \
  "$options" \
  3>&1 1>&2 2>&3)
echo "CHOICE:"
echo "$choices"

# Convert the quoted string into an array
# This safely splits on whitespace while respecting quotes
read -r -a containers <<< "$choices"

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
