# Homelab setup
Setup the homelab by running the following script in the Proxmox shell:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_homelab/create_homelab_container.sh)"
```
Choose advanced settings and make sure to select these options:
- Container type: `privileged`
- MAC address: `bc:24:11:08:52:a3` (for automatic network recognition)

# Dev environment setup
Setup a home assistant devcontainer using the following script:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup_dev_environment/create_dev_environment.sh)"
```
