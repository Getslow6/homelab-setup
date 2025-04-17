echo ""
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%              LXC SETUP - PART 1               %%"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

# Use the Community helper script for a Docker container based on Alpine:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/alpine-docker.sh)"

# Get the container ID of the container with the name 'docker'
CTID=$(pct list | grep -w docker | cut -d " " -f 1)

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
lxc-attach -n "$CTID" -- bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup-lxc.sh)"
