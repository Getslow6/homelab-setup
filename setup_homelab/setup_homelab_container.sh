#!/bin/bash

# Ensure the script stops on errors
set -e

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# Get GitHub repository details from the user
GITHUB_REPOSITORY=$(get_input    "Enter your GitHub repository"                     "GitHub repository" "Getslow6/homelab-config") || error_exit "Failed to get GitHub repository"
GITHUB_USER=$(      get_input    "Enter your GitHub username for committing to Git" "Git Username"      "Getslow6" ) || error_exit "Failed to get GitHub username"
GITHUB_PAT=$(       get_password "Enter your GitHub Personal Access Token (PAT)"    "GitHub PAT")        || error_exit "Failed to get GitHub PAT"
clear
# adduser $USER
# chown $USER: /srv

git config --global credential.helper store
# Make sure that local git uses the already stored credentials
git config --global user.email "$GITHUB_USER@proxmox.local"
git config --global user.name "$GITHUB_USER"

# Clone the GitHub config to the /srv folder
msg_info "Cloning Git repository"

# Ensure folder is empty
rm -rf /srv/.[!.]* 
rm -rf /srv/*

git clone --quiet https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_REPOSITORY} /srv || error_exit "Failed cloning the repository"

# Copy the default database for Dockge, as this stores the credentials.
cp "/srv/applications/dockge/data/dockge.db.configured" "/srv/applications/dockge/data/dockge.db"


msg_ok "Cloned Git repository"

# Ensure local Git uses the stored credentials
cd /srv || error_exit "Failed to change directory to /srv"


git config credential.helper store

# Create Docker networks
msg_info "Creating Docker networks"
docker network create mqtt > /dev/null 2>&1
docker network create proxy > /dev/null 2>&1
docker network create authelia > /dev/null 2>&1
msg_ok "Created Docker networks"

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
    options+=("$container" " " "ON")
  else
    options+=("$container" " " "OFF")
  fi
done

# Function to get user input with a checklist box
SELECTED_CONTAINERS=$(whiptail --backtitle "Homelab setup" --title "Select containers to start" --checklist \
"Choose containers" 37 58 30 \
"${options[@]}" 3>&1 1>&2 2>&3)
clear

# Convert the quoted string into an array
eval "containers=($SELECTED_CONTAINERS)"

# Loop through each container and bring it up
for container in "${containers[@]}"; do
  compose_file="/srv/applications/$container/docker-compose.yml"

  msg_info " Starting Docker Compose for: $container"
  docker compose -f "$compose_file" up -d  > /dev/null 2>&1

  # Check if the command was successful
  if [ $? -eq 0 ]; then
    msg_ok " Container '$container' started successfully"
  else
    msg_error " Failed to start: $container"
  fi
done

