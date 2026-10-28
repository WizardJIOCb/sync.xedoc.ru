#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/var/www/sync.xedoc.ru"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run this script as root: sudo ./scripts/install-systemd.sh"
  exit 1
fi

install -m 0644 "${PROJECT_DIR}/systemd/wizard-sync-vault.service" /etc/systemd/system/wizard-sync-vault.service
install -m 0644 "${PROJECT_DIR}/systemd/wizard-sync.service" /etc/systemd/system/wizard-sync.service

systemctl daemon-reload

echo "Installed systemd services."
echo "Start order after each reboot:"
echo "1. /var/www/sync.xedoc.ru/scripts/unlock-vault.sh mount"
echo "2. sudo systemctl start wizard-sync"
