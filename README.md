# Wizard Sync

Wizard Sync is a self-hosted secret vault built around:

- Obsidian for editing Markdown notes
- Syncthing for device-to-device sync
- gocryptfs for encryption at rest on the server

## Why this layout

The original idea "one encrypted container + sync" sounds simple, but a single container file is a poor match for multi-device synchronization:

- the whole container changes even after a tiny edit
- conflicts are painful
- mobile access is awkward

This repository uses a safer and more sync-friendly variant:

- Obsidian opens a normal Markdown vault
- Syncthing syncs the vault between devices
- the server stores the synced vault on a mounted encrypted filesystem

That gives us:

- convenient access from phone and PC
- offline work
- full-text search in Obsidian
- encrypted storage on the VPS disk
- simple backups

## Server architecture

On the server:

1. `gocryptfs` stores encrypted files in `runtime/vault.encrypted`
2. The encrypted directory is mounted to `runtime/vault`
3. Syncthing sees only the mounted vault and syncs it with devices
4. Syncthing GUI is bound to `127.0.0.1:8384` and should be opened through SSH tunnel

## Project layout

- `docker-compose.yml` - Syncthing node
- `.env.example` - environment variables
- `scripts/bootstrap-ubuntu.sh` - initial server bootstrap
- `scripts/unlock-vault.sh` - mount encrypted vault
- `scripts/lock-vault.sh` - unmount vault
- `scripts/install-systemd.sh` - install services
- `systemd/` - systemd units
- `docs/CLIENT_SETUP.md` - setup guide for PC and phone
- `nginx/sync.xedoc.ru.conf` - reverse proxy for HTTPS access

## Quick start

### 1. Upload project to the server

Clone or copy this repository to:

`/var/www/sync.xedoc.ru`

### 2. Prepare `.env`

Copy `.env.example` to `.env` and adjust values.

### 3. Bootstrap Ubuntu server

```bash
cd /var/www/sync.xedoc.ru
chmod +x scripts/*.sh
./scripts/bootstrap-ubuntu.sh
```

The script installs:

- Docker Engine with Compose plugin
- `gocryptfs`
- required folders

### 4. Create encrypted vault

```bash
cd /var/www/sync.xedoc.ru
./scripts/unlock-vault.sh init
```

This initializes the encrypted directory and mounts it.

### 5. Start Syncthing

```bash
docker compose up -d
```

Important:

- Syncthing is intentionally not configured for automatic boot
- first mount the encrypted vault, then start Syncthing
- this avoids accidental sync against an empty unmounted directory after reboot

### 6. Publish HTTPS endpoint

```bash
sudo ./scripts/install-nginx-site.sh
```

This script:

- installs the nginx vhost for `sync.xedoc.ru`
- requests or refreshes the Let's Encrypt certificate
- enables HTTP Basic Auth in front of Syncthing

### 7. Open Syncthing admin

Preferred production URL:

`https://sync.xedoc.ru`

Fallback if needed:

open via SSH tunnel to `127.0.0.1:8384`

```bash
ssh -L 8384:127.0.0.1:8384 your-user@132.243.118.214
```

Then open:

`http://127.0.0.1:8384`

### 8. Add the vault folder

In Syncthing UI add folder:

`/data/vault`

Set a stable folder ID, for example:

`wizard-sync-vault`

### 9. Connect your devices

Install Syncthing on each device and share the same folder.

For device-side encryption guidance see:

`docs/CLIENT_SETUP.md`

## Important security note

This setup encrypts data at rest on the server. If you also want the server to never see plaintext at all, each client should use its own encrypted filesystem locally and sync the encrypted backing directory, not the decrypted mount. That is possible, but mobile setup becomes more complex.

For most practical cases, this repository gives the best balance between usability and security.
