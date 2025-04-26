# Homelab setup
Setup the homelab by running the following script in the Proxmox shell:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_homelab/create_homelab_container.sh)"
```
Choose advanced settings and make sure to select these options:
- Container type: `privileged`
- MAC address: `bc:24:11:08:52:a3` (for automatic network recognition)


## Container setup
If there is already a container with Docker and Docker compose installed, use this script in the container:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_homelab/setup_homelab_container.sh)"
```

# Devcontainer setup
Setup a home assistant devcontainer using the following script:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_devcontainer/create_devcontainer.sh)"
```

## Container setup
If there is already a container with Docker and Docker compose installed, use this script in the container:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_devcontainer/setup_devcontainer.sh)"
```