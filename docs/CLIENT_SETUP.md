# Client setup

## Recommended device apps

### Windows

- Obsidian
- Syncthing
- Cryptomator or cppcryptfs if you want local encryption too

### Android

- Obsidian
- Syncthing-Fork or Syncthing Android
- Cryptomator or DroidFS if you want local encryption too

## Simplest setup

Best balance of convenience and security:

1. Server uses encrypted storage from this repository
2. PC and phone sync the Obsidian vault through Syncthing
3. Obsidian opens the synced folder directly

This is the easiest daily workflow.

## Maximum-security setup

If you do not want the server to ever store plaintext:

1. Create an encrypted vault locally on each device
2. Open the decrypted mount in Obsidian
3. Point Syncthing to the encrypted backing directory
4. Sync the encrypted files, not the mounted plaintext folder

Important:

- do not sync a single VeraCrypt container as your working vault
- do not sync a mounted directory and expect the server to stay blind to plaintext

For cross-device sync, per-file encryption is much better than one large container.

## Suggested vault structure

```text
Vault/
  00 Inbox.md
  01 Secrets/
    Cards.md
    Accounts.md
    Servers.md
  02 Recovery/
    Backup codes.md
    Emergency contacts.md
  99 Archive/
```

## Good practices

- turn on screen lock on every device
- keep a printed emergency recovery note in a safe place
- back up `runtime/vault.encrypted` from the server
- store Syncthing device IDs in a separate secure note
- enable Syncthing folder versioning for accidental deletions
