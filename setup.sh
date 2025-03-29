echo ""
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%              LXC SETUP - PART 1               %%"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

# Use the Community helper script for Komodo taken from:
# https://community-scripts.github.io/ProxmoxVE/scripts?id=komodo
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/komodo.sh)"

# Get the container ID of the container with the name komodo
CTID=$(pct list | grep komodo | cut -d " " -f 1)

# Rename the hostname of the just created container to 'Dockerhost'
pct set $CTID --hostname dockerhost

# Run additional code inside the just created LXC container
lxc-attach -n "$CTID" -- bash -c "$(wget -qLO - https://github.com/Getslow6/homelab-setup/raw/main/setup-part2.sh)"
