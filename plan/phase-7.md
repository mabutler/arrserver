# Phase 7 — Remote Access & Hardening

> Medium-term working doc for Phase 7.
> Reference `product.md` for decisions already made.

## Goal

Clean URLs for all services, SSL termination, and any remaining hardening before considering loki "production-ready."

## Planned additions

### Nginx Proxy Manager

Reverse proxy so services are accessible via hostname rather than port number (e.g., `sonarr.loki` instead of `loki:8989`). Also handles SSL termination if services are ever exposed beyond Tailscale.

- Runs as a Docker container alongside the arr stack
- Admin UI for managing proxy hosts and certs
- Pairs well with Homarr — Homarr links use clean URLs instead of ports

### SSL

- Internal: self-signed cert or Tailscale's built-in HTTPS (`loki.tail*.ts.net`)
- External: Let's Encrypt (only if services are exposed outside Tailscale)

### Tdarr

Monitors the media library and automatically re-encodes files based on configurable rules (e.g. convert x264 to x265, cap resolution at 1080p). Runs as a Docker container with a separate node agent that does the actual transcoding work.

- Pairs with the arr stack — processes files after Sonarr/Radarr import them
- Useful for normalizing quality and reducing library size over time
- Transcoding is CPU-intensive — assess Vostro 260 performance before committing

## Planned deliverables

- [ ] Add Nginx Proxy Manager to `docker/compose.yml`
- [ ] Configure proxy hosts for all services (Sonarr, Radarr, Prowlarr, Jellyfin, Homarr)
- [ ] Update Homarr links to use clean URLs
- [ ] SSL strategy decided and implemented
