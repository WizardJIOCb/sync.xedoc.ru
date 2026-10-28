#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/var/www/sync.xedoc.ru"
ENCRYPTED_DIR="${PROJECT_DIR}/runtime/vault.encrypted"
MOUNT_DIR="${PROJECT_DIR}/runtime/vault"
MODE="${1:-mount}"

if [[ ! -d "${ENCRYPTED_DIR}" ]]; then
  echo "Encrypted directory not found: ${ENCRYPTED_DIR}"
  exit 1
fi

mkdir -p "${MOUNT_DIR}"

case "${MODE}" in
  init)
    if [[ -f "${ENCRYPTED_DIR}/gocryptfs.conf" ]]; then
      echo "Vault is already initialized."
    else
      echo "Initializing encrypted vault in ${ENCRYPTED_DIR}"
      gocryptfs -init "${ENCRYPTED_DIR}"
    fi
    echo "Mounting vault to ${MOUNT_DIR}"
    gocryptfs "${ENCRYPTED_DIR}" "${MOUNT_DIR}"
    ;;
  mount)
    if mountpoint -q "${MOUNT_DIR}"; then
      echo "Vault is already mounted."
      exit 0
    fi
    echo "Mounting vault to ${MOUNT_DIR}"
    gocryptfs "${ENCRYPTED_DIR}" "${MOUNT_DIR}"
    ;;
  *)
    echo "Usage: $0 [init|mount]"
    exit 1
    ;;
esac
