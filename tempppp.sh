#!/bin/bash

# Load the self-defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup2.func)

clear
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

echo "OPTIONS:"
echo "${options[@]}"

# Show the checklist
START_CONTAINERS=$(get_checklist "Select containers to start" "Choose containers:" "${options[@]}")

echo "START_CONTAINERS:"
echo "$START_CONTAINERS"


# Convert the quoted string into an array
readarray -t containers <<< "$(echo "$START_CONTAINERS" | tr -d '"')"

# Loop through each container and bring it up
for container in "${containers[@]}"; do
  compose_file="/srv/applications/$container/docker-compose.yml"

  msg_info "Starting Docker Compose for: $container"

  if docker compose -f "$compose_file" up -d; then
    msg_ok "Container '$container' started successfully"
  else
    msg_error "Failed to start: $container"
  fi
done

