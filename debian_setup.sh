#!/usr/bin/env bash
#
# setup-periphery-node.sh
# - Updates Debian
# - Installs Komodo Periphery agent (systemd)
# - Creates Homelab/appdata and Homelab/app folders
#
# Run as root (or with sudo).

set -euo pipefail

# ---- must be root -----------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root (e.g. sudo $0)" >&2
  exit 1
fi

# ---- prompt for missing variables --------------------------------------
CORE_ADDRESS="${CORE_ADDRESS:-}"
ONBOARDING_KEY="${ONBOARDING_KEY:-}"
CONNECT_AS="${CONNECT_AS:-}"
BASE_DIR="${BASE_DIR:-/opt/Homelab}"

if [[ -z "$CORE_ADDRESS" ]]; then
  read -rp "Komodo Core address (e.g. https://core.example.com): " CORE_ADDRESS
fi

if [[ -z "$ONBOARDING_KEY" ]]; then
  read -rp "Onboarding key (from Komodo Core > Settings > Onboarding): " ONBOARDING_KEY
fi

if [[ -z "$CONNECT_AS" ]]; then
  read -rp "Connect-as name [default: $(hostname)]: " CONNECT_AS
  CONNECT_AS="${CONNECT_AS:-$(hostname)}"
fi

read -rp "Base directory for Homelab folders [default: $BASE_DIR]: " BASE_DIR_INPUT
BASE_DIR="${BASE_DIR_INPUT:-$BASE_DIR}"

echo
echo "== Using =="
echo "Core address:   $CORE_ADDRESS"
echo "Connect as:     $CONNECT_AS"
echo "Base directory: $BASE_DIR"
echo "Onboarding key: ${ONBOARDING_KEY:0:6}... (hidden)"
echo

# ---- update system ------------------------------------------------------
echo "==> Updating Debian..."
apt-get update -y
apt-get upgrade -y

# ---- create folder structure --------------------------------------------
echo "==> Creating folder structure under $BASE_DIR..."
mkdir -p "$BASE_DIR/appdata"
mkdir -p "$BASE_DIR/app"

# ---- install docker -------------------------------------------------------
if command -v docker >/dev/null 2>&1; then
  echo "==> Docker already installed, skipping."
else
  echo "==> Installing Docker (official convenience script)..."
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
  systemctl enable docker --now
fi

# ---- add invoking (real) user to docker group ------------------------------
REAL_USER="${SUDO_USER:-$USER}"
if [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]]; then
  usermod -aG docker "$REAL_USER"
  echo "==> Added $REAL_USER to the docker group (log out/in for it to take effect)."
fi

# ---- install periphery ----------------------------------------------------
echo "==> Installing Komodo Periphery..."
curl -sSL https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py \
  | python3 - \
    --core-address "$CORE_ADDRESS" \
    --connect-as "$CONNECT_AS" \
    --onboarding-key "$ONBOARDING_KEY" \
    --force-service-file

# ---- enable and start service -------------------------------------------
echo "==> Enabling and starting periphery service..."
systemctl daemon-reload
systemctl enable periphery --now

echo
echo "==> Done. Checking service status:"
systemctl status periphery --no-pager || true

echo
echo "Folders created:"
echo "  $BASE_DIR/appdata"
echo "  $BASE_DIR/app"
echo
echo "Check logs with: journalctl -u periphery -f"
