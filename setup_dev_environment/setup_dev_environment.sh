#!/bin/bash

# Ensure the script stops on errors
set -e

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# Get GitHub repository details from the user
GITHUB_REPOSITORY=$(get_input    "Enter your Custom component GitHub repository" "GitHub repository" "Getslow6/monitor_docker") || error_exit "Failed to get GitHub repository"
GITHUB_USER=$(      get_input    "Enter your GitHub username for committing to Git" "Git Username"   "Getslow6" ) || error_exit "Failed to get GitHub username"
GITHUB_PAT=$(       get_password "Enter your GitHub Personal Access Token (PAT)"    "GitHub PAT")        || error_exit "Failed to get GitHub PAT"
clear

git config --global credential.helper store
# Make sure that local git uses the already stored credentials
git config --global user.email "$GITHUB_USER@devcontainer.local"
git config --global user.name "$GITHUB_USER"

# Clone the GitHub config to the /source folder
msg_info "Cloning Git repository"
git clone --quiet https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_REPOSITORY} /source || error_exit "Failed cloning the repository"
msg_ok "Cloned Git repository"

# Ensure local Git uses the stored credentials
cd /source || error_exit "Failed to change directory to /srv"

git config credential.helper store


BASE_DIR="/srv/applications"
REPO_URL="https://github.com/Getslow6/homelab-setup/raw/main/setup_dev_environment/applications"
APPS=("code-server" "home-assistant")

# Download all docker compose files and run them
for APP in "${APPS[@]}"; do
  msg_info "Setting up $APP"
  mkdir -p "$BASE_DIR/$APP" >/dev/null 2>&1
  curl -sSL -o "$BASE_DIR/$APP/docker-compose.yml" \
    "$REPO_URL/$APP/docker-compose.yml" >/dev/null 2>&1
  docker compose -f "$BASE_DIR/$APP/docker-compose.yml" up -d 
  msg_ok "$APP is now running"
done
