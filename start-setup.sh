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

# Reboot to finalise changing the hostname
pct reboot $CTID
echo "Rebooting container, waiting for restart..."
sleep 2
while [[ "$(pct status "$CTID" | awk '{print $2}')" != "running" ]]; do
    sleep 2
done
echo "Containter has restarted"

# Run additional code inside the just created LXC container
lxc-attach -n "$CTID" -- bash -c "$(wget -qLO - https://github.com/Getslow6/homelab-setup/raw/main/setup-lxc.sh)"
