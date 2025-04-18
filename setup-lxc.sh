#!/bin/bash

# Load the self-defined support functions
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

# Clone the GitHub config to the /srv folder
echo "▶️ Cloning Git repository"
git clone --quiet https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_REPOSITORY} /srv || error_exit "Failed cloning the repository"
echo "✅ Cloned Git repository"

# Ensure local Git uses the stored credentials
cd /srv || error_exit "Failed to change directory to /srv"
git config credential.helper store

# Create Docker networks
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
options=()
for container in $containerlist; do
  if echo "$containers_on" | grep -qw "$container"; then
    options+=("$container" "$container" "ON")
  else
    options+=("$container" "$container" "OFF")
  fi
done

# Show the checklist

START_CONTAINERS=$(get_input    "Select containers to start" "Choose containers:" "${options[@]}") || error_exit "Failed to get select startup containers"


# Convert the quoted string into an array
readarray -t containers <<< "$(echo "$START_CONTAINERS" | tr -d '"')"

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
