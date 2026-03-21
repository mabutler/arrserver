# Phase 5 — Media Server

> Medium-term working doc for Phase 5.
> Reference `product.md` for decisions already made.

## Goal

A media server and dashboard running on loki — browse and stream the library, and access all services from one place.

## Decision: Jellyfin

**Jellyfin** — open source, no account required, self-hosted. No phone-home, no subscription, no Emby/Plex lock-in. Settled.

## Design

### App

| App | Role | Port |
|-----|------|------|
| Jellyfin | Media server / streaming | 8096 (HTTP), 8920 (HTTPS optional) |

### Compose integration

Add Jellyfin as a new service in `docker/compose.yml` alongside the arr stack. Same `arr-net` bridge network so all services can reach each other by name if needed.

### Volume layout

| Path on host | Purpose |
|---|---|
| `/opt/arrconfig/jellyfin` | Jellyfin config and metadata cache |
| `/data/media` | Media library root (read-only mount in container) |

Mount `/data/media` read-only in Jellyfin — it should never write to the library.

### PUID/PGID

Same as arr stack: `mbutler` (UID 1000 / GID 1000).

### Hardware transcoding

Defer to a later phase. Start with software transcoding; revisit if performance is a problem.

### Library structure (from Phase 3)

Jellyfin expects conventional folder names for library detection:

| Jellyfin library | Host path |
|---|---|
| Movies | `/data/media/movies` |
| TV Shows | `/data/media/tv` |

These paths already match what Radarr and Sonarr are configured to use.

### Post-deploy config (manual)

After the container starts, configure libraries in the Jellyfin UI:
- Add Movies library → `/data/media/movies`
- Add TV Shows library → `/data/media/tv`
- Create admin account on first run

## Deliverables

- [x] Add Jellyfin service to `docker/compose.yml`
- [x] Add Ansible task in `ansible/playbooks/arr.yml` to create `/opt/arrconfig/jellyfin` and restart compose
- [x] Jellyfin UI reachable on LAN and over Tailscale
- [ ] Libraries configured and media visible (manual — done in Jellyfin UI after first run, deferred until Phase 3 storage is set up)
