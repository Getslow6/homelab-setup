
# Use the Community helper script for a Docker container based on Debian:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/docker.sh)"

# Load self defined support functions
source <(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup.func)

CTID=$(get_CTID)
lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_devcontainer/setup_devcontainer.sh)"
