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

## Planned deliverables

- [ ] Add Nginx Proxy Manager to `docker/compose.yml`
- [ ] Configure proxy hosts for all services (Sonarr, Radarr, Prowlarr, Jellyfin, Homarr)
- [ ] Update Homarr links to use clean URLs
- [ ] SSL strategy decided and implemented
