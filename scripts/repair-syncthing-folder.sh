#!/usr/bin/env bash
set -euo pipefail

CONFIG="/var/www/sync.xedoc.ru/runtime/syncthing-config/config.xml"

if [[ ! -f "${CONFIG}" ]]; then
  echo "Config not found: ${CONFIG}"
  exit 1
fi

cp "${CONFIG}" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

python3 - <<'PY'
from pathlib import Path

config = Path("/var/www/sync.xedoc.ru/runtime/syncthing-config/config.xml")
text = config.read_text(encoding="utf-8")
text = text.replace(
    '<folder id="wizard-sync-vault" label="Wizard" path="Sync"',
    '<folder id="wizard-sync-vault" label="Wizard Sync Vault" path="/data/vault"',
)
config.write_text(text, encoding="utf-8")
PY

docker restart wizard-sync >/dev/null
echo "Folder config repaired."
