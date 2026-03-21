# Phase 6 — Backups

> Medium-term working doc for Phase 6.
> Reference `product.md` for decisions already made.

## Goal

Automated, scheduled backups of all persistent state on loki — app configs, media library, and any other files that can't be reproduced from the repo.

## Decision: Restic

Restic — fast, encrypted, deduplicating backup tool. Supports local and remote destinations (SFTP, S3, B2, etc.). Destination TBD when ready to implement.

## What to back up

| Path | Contents | Priority | Notes |
|------|----------|----------|-------|
| `/opt/arrconfig` | Sonarr/Radarr/Prowlarr/Jellyfin/Homarr databases and settings | High | Small, critical — losing this means re-adding everything |
| `/data/media` | Media library | Medium | Large — re-downloadable in theory, but slow to recover |
| `/data/torrents` | Pending torrent files | Low | Can be re-added manually |

## Design

- Restic runs on systemd timers (separate schedules for configs vs. media)
- App configs backed up frequently (e.g., daily)
- Media backed up less frequently (e.g., weekly) given size
- Retention policy TBD — at minimum keep last N snapshots
- Backup destination TBD: external drive, remote machine over SFTP, or cloud (B2/S3)

## Planned deliverables

- [ ] Choose backup destination
- [ ] `ansible/playbooks/backup.yml` — installs Restic, configures repo, deploys systemd services and timers
- [ ] Systemd service + timer for config backup (daily)
- [ ] Systemd service + timer for media backup (weekly)
- [ ] Documented restore procedure
