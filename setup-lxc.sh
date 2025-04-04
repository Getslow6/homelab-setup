
GITHUB_REPOSITORY=$(whiptail --backtitle "Homelab setup" \
                             --inputbox "\nEnter your GitHub repository" 9 58 Getslow6/homelab-setup\
                             --title "GitHub repository" \
                             3>&1 1>&2 2>&3)

GITHUB_USER=$(whiptail --backtitle "Homelab setup" \
                    --inputbox "\nEnter your GithHub username for committing to Git" 9 58 \
                    --title "Git Username" \
                    3>&1 1>&2 2>&3)
                    
GITHUB_PAT=$(whiptail --backtitle "Homelab setup" \
                      --passwordbox "\nEnter your GitHub Personal Access Token (PAT)" 9 58 \
                      --title "GitHub PAT" \
                      3>&1 1>&2 2>&3)



# LOCAL_USER=$(whiptail --backtitle "Homelab setup" \
#                     --inputbox "\nEnter your Container username for use inside the LXC container" 9 58 \
#                     --title "Git Username" \
#                     3>&1 1>&2 2>&3)

# GIT_PASSPHRASE=$(whiptail --backtitle "Homelab setup" \
#                           --passwordbox "\nEnter a passphrase to secure the SSH key. If you leave it blank, no passphrase will be used." 9 58 \
#                           --title "SSH key Passphrase" \
#                           3>&1 1>&2 2>&3)


# adduser $USER
# chown $USER: /srv

git config --global credential.helper store
# Make sure that local git uses the already stored credentials
git config --global user.email "$GITHUB_USER@proxmox.local"
git config --global user.name $GITHUB_USER

# # We will generate an SSH key to authenticate with Github
# # -f specifies where the SSH key is stored
# # -N specifies the new passphrase
# # -q makes the execution silent
# # <<<y will answer 'yes' if there is already an SSH key in the target folder
# KEY_LOCATION=$HOME/.ssh/id_ed25519
# ssh-keygen -t ed25519 -C $GIT_MAIL -f $KEY_LOCATION -N $GIT_PASSPHRASE -q <<<y
# clear
# # If the passphrase is not empty
# if [[ ! -z "$GIT_PASSPHRASE" ]]; then
#   GIT_SAVEPASSPHRASE=$(whiptail --backtitle "Homelab setup" \
#                             --yesno "\nDo do want to save the passhrase to the SSH agent, so it doesn't need entering everytime you want to access your repository?" 11 58 \
#                             --title "Save SSH key passphrase?" \
#                             3>&1 1>&2 2>&3)
#   if $GIT_SAVEPASSPHRASE; then
#     # Start an SSH agent
#     eval "$(ssh-agent -s)"

#     # Save the SSH key to the agent
#     ssh-add $KEY_LOCATION
#   fi
# fi

# echo ""
# echo "An SSH key has been generated. This key needs to be added to your Github account. Copy the following line and add it to your account:"
# echo ""
# cat ~/.ssh/id_ed25519.pub
# echo ""

# Clone the github config to the /srv folder
echo "Cloning Git repository"
git clone --quiet https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_REPOSITORY} /srv
echo "Cloned Git repository"

# Make sure that local git uses the already stored credentials
cd /srv
git config credential.helper store
