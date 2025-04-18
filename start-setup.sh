# Use the Community helper script for a Docker container based on Alpine:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/alpine-docker.sh)"

# Function to get user input using whiptail
get_input() {
    local prompt="$1"
    local title="$2"
    local default="$3"
    whiptail --backtitle "Homelab setup" --inputbox "\n$prompt" 9 58 "$default" --title "$title" 3>&1 1>&2 2>&3
}

# Get the LXC container config file that is edited the last and strip it from .conf
CTID_DEFAULT=$(ls -Art  /etc/pve/lxc/ | tail -n 1 | sed 's/\.conf$//')

# Get GitHub repository details from the user
CTID=$(get_input "Enter the container ID of the container you just created" "Container ID" "$CTID_DEFAULT" ) || error_exit "Failed to get Container ID"

# Check if CTID is defined and bigger than 0
if [[ -n "$CTID" && "$CTID" -gt 0 ]]; then
    # Run additional code inside the just created LXC container
    lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup-lxc.sh)"
else
    echo "Script stopped"
fi
