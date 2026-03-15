# Phase 4 — Arr Stack

> Medium-term working doc for Phase 4.
> Reference `product.md` for decisions already made.

## Goal

Sonarr, Radarr, and Prowlarr running in Docker Compose, reachable on the local network and via Tailscale.

## Design

### Apps

| App | Role | Port |
|-----|------|------|
| Sonarr | TV series management | 8989 |
| Radarr | Movie management | 7878 |
| Prowlarr | Indexer manager | 9696 |

### Compose file

`docker/compose.yml` in this repo. Ansible deploys it by copying to the server and running `docker compose up -d`.

### Volume layout

| Path on host | Purpose |
|---|---|
| `/opt/arrconfig/sonarr` | Sonarr config |
| `/opt/arrconfig/radarr` | Radarr config |
| `/opt/arrconfig/prowlarr` | Prowlarr config |
| `/data/media` | Media library (mergerfs pool — stub until Phase 3) |
| `/data/downloads` | Completed downloads landing zone (stub until Phase 3) |

Config dirs live outside the repo. Ansible creates them before starting the stack.

### PUID/PGID

Containers run as `mbutler` (UID 1000 / GID 1000). Set in compose via environment vars. Confirm UID/GID on the machine with `id mbutler` if unsure.

### Networking

All containers on a shared Docker bridge network (`arr-net`) so they can reach each other by service name. Ports bound to `0.0.0.0` so they're reachable on the LAN and over Tailscale.

### Post-deploy config (manual)

Some wiring between apps can't be automated — needs to be done in the UIs after first boot:
- Add Prowlarr as indexer source in Sonarr and Radarr
- Configure download client in Sonarr and Radarr (Phase 3 dependency — download client is on another machine)
- Set root folders in Sonarr (`/data/media/tv`) and Radarr (`/data/media/movies`)

## Deliverables

- [ ] `docker/compose.yml` — Sonarr, Radarr, Prowlarr
- [ ] `ansible/playbooks/arr.yml` — creates config dirs, deploys compose, starts stack
- [ ] Ansible playbook tested in VM — all three UIs reachable
