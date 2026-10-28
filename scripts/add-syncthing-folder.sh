#!/usr/bin/env bash
set -euo pipefail

CONFIG="/var/www/sync.xedoc.ru/runtime/syncthing-config/config.xml"
FOLDER_ID="${1:-wizard-sync-vault}"
FOLDER_LABEL="${2:-Wizard Sync Vault}"
FOLDER_PATH="${3:-/data/vault}"

if [[ ! -f "${CONFIG}" ]]; then
  echo "Config not found: ${CONFIG}"
  exit 1
fi

DEVICE_ID="$(sed -n 's:.*<device id="\([^"]*\)".*:\1:p' "${CONFIG}" | head -n 1)"

if [[ -z "${DEVICE_ID}" ]]; then
  echo "Could not detect local device ID from ${CONFIG}"
  exit 1
fi

if grep -q "folder id=\"${FOLDER_ID}\"" "${CONFIG}"; then
  echo "Folder already exists: ${FOLDER_ID}"
  exit 0
fi

cp "${CONFIG}" "${CONFIG}.bak.$(date +%Y%m%d%H%M%S)"

FOLDER_XML=$(cat <<EOF
    <folder id="${FOLDER_ID}" label="${FOLDER_LABEL}" path="${FOLDER_PATH}" type="sendreceive" rescanIntervalS="3600" fsWatcherEnabled="true" fsWatcherDelayS="10" fsWatcherTimeoutS="0" ignorePerms="false" autoNormalize="true">
        <filesystemType>basic</filesystemType>
        <device id="${DEVICE_ID}" introducedBy=""></device>
        <minDiskFree unit="%">1</minDiskFree>
        <versioning>
            <cleanupIntervalS>3600</cleanupIntervalS>
            <fsPath>/.stversions</fsPath>
            <fsType>trashcan</fsType>
        </versioning>
        <copiers>0</copiers>
        <pullerMaxPendingKiB>0</pullerMaxPendingKiB>
        <hashers>0</hashers>
        <order>random</order>
        <ignoreDelete>false</ignoreDelete>
        <scanProgressIntervalS>0</scanProgressIntervalS>
        <pullerPauseS>0</pullerPauseS>
        <pullerDelayS>1</pullerDelayS>
        <maxConflicts>10</maxConflicts>
        <disableSparseFiles>false</disableSparseFiles>
        <paused>false</paused>
        <markerName>.stfolder</markerName>
        <copyOwnershipFromParent>false</copyOwnershipFromParent>
        <modTimeWindowS>0</modTimeWindowS>
        <maxConcurrentWrites>16</maxConcurrentWrites>
        <disableFsync>false</disableFsync>
        <blockPullOrder>standard</blockPullOrder>
        <copyRangeMethod>standard</copyRangeMethod>
        <caseSensitiveFS>false</caseSensitiveFS>
        <junctionsAsDirs>false</junctionsAsDirs>
        <syncOwnership>false</syncOwnership>
        <sendOwnership>false</sendOwnership>
        <syncXattrs>false</syncXattrs>
        <sendXattrs>false</sendXattrs>
        <blockIndexing>true</blockIndexing>
        <xattrFilter>
            <maxSingleEntrySize>1024</maxSingleEntrySize>
            <maxTotalSize>4096</maxTotalSize>
        </xattrFilter>
    </folder>
EOF
)

python3 - <<PY
from pathlib import Path
config = Path("${CONFIG}")
text = config.read_text(encoding="utf-8")
marker = "    <defaults>"
folder_xml = """${FOLDER_XML}
"""
if marker not in text:
    raise SystemExit("Could not find <defaults> section")
text = text.replace(marker, folder_xml + marker, 1)
config.write_text(text, encoding="utf-8")
PY

docker restart wizard-sync >/dev/null
echo "Folder added: ${FOLDER_ID} -> ${FOLDER_PATH}"
