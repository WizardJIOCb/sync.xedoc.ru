#!/usr/bin/env bash
set -euo pipefail

CONFIG="/var/www/sync.xedoc.ru/runtime/syncthing-config/config.xml"
DEVICE_ID="${1:-}"

if [[ -z "${DEVICE_ID}" ]]; then
  echo "Usage: $0 <device-id>"
  exit 1
fi

cp "${CONFIG}" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

python3 - <<PY
from pathlib import Path

device_id = "${DEVICE_ID}"
config = Path("${CONFIG}")
text = config.read_text(encoding="utf-8")

marker = f'''        <device id="{device_id}" introducedBy="">
            <encryptionPassword></encryptionPassword>
        </device>
'''

if marker not in text:
    anchor = '''        <device id="4KHXQXV-W2OKIYR-VQD4TEL-J3JJD55-2JXSEUR-ETJ3WFA-ZF6X47O-J2LXTAH" introducedBy="">
            <encryptionPassword></encryptionPassword>
        </device>
'''
    text = text.replace(anchor, marker + anchor, 1)

config.write_text(text, encoding="utf-8")
PY

docker restart wizard-sync >/dev/null
echo "Server folder now includes device: ${DEVICE_ID}"
