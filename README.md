# Homelab setup
Setup the homelab by running the following script in the Proxmox shell:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/start-setup.sh)"
```
Choose advanced settings and make sure to select these options:
- Container type: `privileged`


# Container setup
If there is already an Alpine (!) container with Docker and Docker compose installed, use this script in the container:
```
bash -c "$(curl -fsSL https://github.com/Getslow6/homelab-setup/raw/main/setup-lxc.sh)"
```