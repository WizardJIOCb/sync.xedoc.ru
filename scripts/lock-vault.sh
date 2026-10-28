#!/usr/bin/env bash
set -euo pipefail

MOUNT_DIR="/var/www/sync.xedoc.ru/runtime/vault"

if mountpoint -q "${MOUNT_DIR}"; then
  fusermount -u "${MOUNT_DIR}"
  echo "Vault unmounted."
else
  echo "Vault is not mounted."
fi
