#!/bin/bash

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

# Ensure the script stops on errors
set -e

# Install Docker
curl -fsSL https://get.docker.com | sh

# Setup docker to auto start on boot
systemctl enable docker
systemctl start docker
usermod -aG docker $USER

GITHUB_REPOSITORY=$(get_input  "Enter your (forked) Home Assistant Github repository" "GitHub repository" "Getslow6/core") || error_exit "Failed to get GitHub repository"
git clone --quiet --branch master --single-branch --depth 1 https://github.com/${GITHUB_REPOSITORY} homeassistant || error_exit "Failed cloning the repository"

cd homeassistant



