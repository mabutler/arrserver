# Phase 3 — Storage Layout & File Sharing

> Medium-term working doc for Phase 3.
> Reference `product.md` for decisions already made.

## Status

**PARTIAL** — File transfer automation is designed and coded. Storage (mergerfs/snapraid) requires bare metal.

---

## TODO (do before starting storage portion)

- [ ] Boot bare metal, collect UUIDs for all 4 drives (`lsblk -f` or `blkid`)
- [ ] Record UUIDs in `ansible/group_vars/all.yml` under `storage_drives`
- [ ] Decide on PUID/PGID for Docker container permissions

---

## Goal

Data drives mounted and pooled; completed downloads land on loki automatically from the remote download server.

---

## File Transfer — DONE (pending real remote creds)

### Decision: rsync over SSH

Torrent files are pushed to the remote; completed downloads are pulled back. Both run on systemd timers.

### Flow

```
/data/torrents/  →  rsync push  →  remote watch dir  →  qBittorrent downloads
remote completed dir  →  rsync pull  →  /data/downloads/  →  Sonarr/Radarr import  →  /data/media/
```

### rsync flags

| Flag | Reason |
|------|--------|
| `--ignore-existing` | Prevents re-downloading files already in `/data/downloads` |
| `--partial` | Resumes interrupted transfers instead of starting over |
| `--bwlimit` | Rate limiting — configured in `all.yml` (default 3 MB/s) |

### Import mode: hardlinks

Sonarr/Radarr are configured to use hardlinks when importing from `/data/downloads` to `/data/media`. On mergerfs, hardlinks work when source and dest land on the same underlying drive; when they don't, mergerfs falls back to a copy. Either way, pruning `/data/downloads` is safe — data in `/data/media` is never at risk.

### Pruning workflow

When finished with a download:
1. Remove torrent from qBittorrent (use "remove + delete data") — stops seeding and deletes remote data
2. Delete the `.torrent` file from local `/data/torrents`
3. Delete the data from local `/data/downloads`

Step 3 can happen any time after step 1. Media in `/data/media` is untouched throughout.

### Configuration

Fill in the `PLACEHOLDER` values in `ansible/inventory/group_vars/all.yml` **before running bootstrap**:

| Var | Description |
|-----|-------------|
| `sync_remote_host` | IP or hostname of the remote download machine |
| `sync_remote_user` | SSH user on the remote machine |
| `sync_remote_watch_dir` | Directory qBittorrent watches for `.torrent` files |
| `sync_remote_downloads_dir` | Directory qBittorrent puts completed downloads |
| `sync_bwlimit_kbps` | rsync bandwidth cap (default 3000 = ~3 MB/s) |
| `sync_interval` | How often the timers fire (default 5min) |

bootstrap.sh reads `sync_remote_host` and `sync_remote_user` from `all.yml` and will error out if they're still PLACEHOLDER.

### SSH key setup

Handled automatically by bootstrap.sh on first run:
- Generates an ed25519 keypair at `sync_ssh_key_path`
- Prompts for the remote server password (used once for `ssh-copy-id`)
- Installs the public key on the remote — password is never needed again

### Running the sync playbook

Once bootstrap has run and the SSH key is installed:

```bash
ansible-playbook ansible/playbooks/sync.yml -i ansible/inventory/hosts.yml --ask-become-pass
```

This verifies the SSH connection, deploys the systemd services and timers, and starts them.

---

## Storage — requires bare metal

### Planned deliverables

- mergerfs pool across 3 data drives, snapraid parity configured
- Drives referenced by UUID in Ansible vars (never by `/dev/sdX`)
- Storage directory structure defined (`/data/media/movies`, `/data/media/tv`, `/data/downloads`, `/data/torrents`)
