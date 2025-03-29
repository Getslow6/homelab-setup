
GITHUB_URL=$(whiptail --backtitle "Homelab setup" \
                      --input "\nEnter your GitHub repository URL:" 9 58 \
                      --title "GitHub repository" \
                      3>&1 1>&2 2>&3)
GITHUB_PAT=$(whiptail --backtitle "Homelab setup" \
                      --passwordbox "\nEnter your GitHub Personal Access Token (PAT):" 9 58 \
                      --title "GitHub PAT" \
                      3>&1 1>&2 2>&3)

$GITHUB_URL
$GITHUB_PAT
