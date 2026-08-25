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

# ---- default variables --------------------------------------
CORE_ADDRESS="http://192.168.2.8:9120"
read -rp "Komodo Core address (e.g. https://core.example.com): " CORE_ADDRESS_INPUT
CORE_ADDRESS="${CORE_ADDRESS_INPUT:-$CORE_ADDRESS}"

CONNECT_AS="$(hostname)"
read -rp "Connect-as name [default: $CONNECT_AS]: " CONNECT_AS_INPUT
CONNECT_AS="${CONNECT_AS_INPUT:-$(hostname)}"

ONBOARDING_KEY="O_default_O"
read -rp "Onboarding key (from Komodo Core > Settings > Onboarding) [default: $ONBOARDING_KEY]: " ONBOARDING_KEY_INPUT
ONBOARDING_KEY="${ONBOARDING_KEY_INPUT:-$ONBOARDING_KEY}"

BASE_DIR="/opt/Homelab"
read -rp "Base directory for Homelab folders [default: $BASE_DIR]: " BASE_DIR_INPUT
BASE_DIR="${BASE_DIR_INPUT:-$BASE_DIR}"

echo
echo "== Using =="
echo "Core address:   $CORE_ADDRESS"
echo "Connect as:     $CONNECT_AS"
echo "Base directory: $BASE_DIR"
echo "Onboarding key: $ONBOARDING_KEY"
echo

# ---- update system ------------------------------------------------------
echo "==> Updating Debian..."
apt-get update -qq
apt-get upgrade -y -qq

# ---- create folder structure --------------------------------------------
echo "==> Creating folder structure under $BASE_DIR..."
mkdir -p "$BASE_DIR/appdata"
mkdir -p "$BASE_DIR/app"

# ---- install docker -------------------------------------------------------
if command -v docker >/dev/null 2>&1; then
  echo "==> Docker already installed, skipping."
else
  echo "==> Installing Docker (official convenience script)..."
  wget -O /tmp/get-docker.sh https://get.docker.com
  sh /tmp/get-docker.sh
  rm -f /tmp/get-docker.sh
  systemctl enable docker --now
fi

# ---- install periphery ----------------------------------------------------
echo "==> Installing Komodo Periphery..."
wget -qO- https://raw.githubusercontent.com/moghtech/komodo/main/scripts/setup-periphery.py \
  | python3 - \
    --core-address "$CORE_ADDRESS" \
    --connect-as "$CONNECT_AS" \
    --onboarding-key "$ONBOARDING_KEY"

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
