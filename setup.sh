echo ""
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%              INSTALLATION SCRIPT              %%"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

# Use the Community helper script for Komodo taken from:
# https://community-scripts.github.io/ProxmoxVE/scripts?id=komodo
bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/ct/komodo.sh)"

# Run additional code inside the just created LXC container
hostname
#lxc-attach -n "$CTID" -- bash -c "$(wget -qLO - https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/$var_install.sh)"
