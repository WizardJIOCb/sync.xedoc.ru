#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/var/www/sync.xedoc.ru"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script as root: sudo ./scripts/bootstrap-ubuntu.sh"
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release gocryptfs

install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
fi

ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

mkdir -p "${PROJECT_DIR}/runtime/syncthing-config"
mkdir -p "${PROJECT_DIR}/runtime/vault"
mkdir -p "${PROJECT_DIR}/runtime/vault.encrypted"

chmod 700 "${PROJECT_DIR}/runtime/vault.encrypted"

echo
echo "Bootstrap complete."
echo "Next steps:"
echo "1. cp ${PROJECT_DIR}/.env.example ${PROJECT_DIR}/.env"
echo "2. ./scripts/unlock-vault.sh init"
echo "3. docker compose up -d"
