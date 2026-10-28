#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="/var/www/sync.xedoc.ru/runtime/vault"

mkdir -p "${VAULT_DIR}/01 Secrets"
mkdir -p "${VAULT_DIR}/02 Recovery"
mkdir -p "${VAULT_DIR}/99 Archive"

touch "${VAULT_DIR}/.stfolder"

cat >"${VAULT_DIR}/00 Inbox.md" <<'EOF'
# Inbox

- Quick notes
- Temporary secrets before sorting
- Things to review later
EOF

cat >"${VAULT_DIR}/01 Secrets/Accounts.md" <<'EOF'
# Accounts

## Template

- Service:
- Login:
- Email:
- 2FA:
- Recovery:
- Notes:
EOF

cat >"${VAULT_DIR}/01 Secrets/Cards.md" <<'EOF'
# Cards

## Template

- Bank:
- Holder:
- Last 4 digits:
- Expiration:
- PIN hint:
- Notes:
EOF

cat >"${VAULT_DIR}/01 Secrets/Servers.md" <<'EOF'
# Servers

## Template

- Host:
- IP:
- SSH user:
- Auth method:
- Recovery:
- Notes:
EOF

cat >"${VAULT_DIR}/02 Recovery/Backup codes.md" <<'EOF'
# Backup codes

Store one service per section and mark used codes immediately.
EOF

cat >"${VAULT_DIR}/02 Recovery/Emergency contacts.md" <<'EOF'
# Emergency contacts

- Name:
- Phone:
- Relationship:
- Notes:
EOF

cat >"${VAULT_DIR}/README.md" <<'EOF'
# Wizard Sync Vault

This vault is intended for Obsidian + Syncthing.

Recommended rules:

- edit only on trusted devices
- keep screen lock enabled
- do not share this folder with unknown devices
- keep backup codes updated
EOF

echo "Vault starter content created in ${VAULT_DIR}"
