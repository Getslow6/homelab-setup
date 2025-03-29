
GITHUB_URL=$(whiptail --backtitle "Homelab setup" \
                      --inputbox "\nEnter your GitHub repository URL" 9 58 \
                      --title "GitHub repository" \
                      3>&1 1>&2 2>&3)
GITHUB_PAT=$(whiptail --backtitle "Homelab setup" \
                      --passwordbox "\nEnter your GitHub Personal Access Token (PAT)" 9 58 \
                      --title "GitHub PAT" \
                      3>&1 1>&2 2>&3)

GIT_USER=$(whiptail --backtitle "Homelab setup" \
                    --passwordbox "\nEnter your preferred username for committing to Git" 9 58 \
                    --title "Git Username" \
                    3>&1 1>&2 2>&3)

GIT_MAIL=$(whiptail --backtitle "Homelab setup" \
                    --passwordbox "\nEnter your (fictive) e-mail adress for committing to Git" 9 58 \
                    --title "Git e-mail adress" \
                    3>&1 1>&2 2>&3)

GIT_PASSPHRASE=$(whiptail --backtitle "Homelab setup" \
                          --passwordbox "\nEnter a passphrase to secure the SSH key" 9 58 \
                          --title "SSH key Passphrase" \
                          3>&1 1>&2 2>&3)

GIT_SAVEPASSPHRASE=$(whiptail --backtitle "Homelab setup" \
                          --yesno "\nDo do want to save the passhrase to the SSH agent, so it doesn't need entering everytime you want to access your repository?" 11 58 \
                          --title "Save SSH key passphrase?" \
                          3>&1 1>&2 2>&3)


# We will generate an SSH key to authenticate with Github
# ssh-keygen -t ed25519 -C $GIT_MAIL -f $HOME/.ssh/id_rsa
