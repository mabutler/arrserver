# arrserver — Product Plan

> This document is long-term memory for the life of the project.
> It captures goals, decisions, conventions, and phase summaries.
> Update it when decisions change or new context is established.

---

## Project Goal

Automate the full setup of a dedicated home server running Arch Linux, from bare metal through a working arr media stack. The setup should be largely hands-off after a minimal copy-paste to kick things off.

Target machine hostname: **loki**

---

## High-Level Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | OS Installation (archinstall) | In progress |
| 2 | Post-Install Bootstrap & Automation | Not started |
| 3 | File Sharing & Storage Layout | Not started |
| 4 | Arr Stack (Docker Compose) | Not started |
| 5 | Media Server | Not started |
| 6+ | Future apps | TBD |

---

## Key Decisions

### OS: Arch Linux via archinstall
- `archinstall` handles the full OS install from config files hosted in this repo
- Config files: `arch/configuration.json`, `arch/credentials.json`
- Bootstrap command (from README): one `archinstall --config-url ...` command — that's the only manual step
- **Bootloader**: systemd-boot (from config — use Arch defaults, don't second-guess)
- **Filesystem**: ext4 on `/dev/sda`
- **Swap**: enabled (zstd compression)
- **Network**: NetworkManager
- **Timezone**: America/New_York
- **Locale**: en_US.UTF-8
- **User**: `mbutler` (sudo)

### Base packages installed at archinstall time
Minimum needed to bootstrap Ansible: `git`, `curl` (or `wget`)

Additional needed packages: `zsh`, `tmux`, `vim`, `rsync`, `smartmontools`, `tailscale`, `base-devel`

### archinstall profile
Server profile with: **Cockpit**, **Docker**, **sshd**

### Automation approach: Hybrid (Shell bootstrap → Ansible)
- A minimal shell script (or archinstall `custom_commands`) installs Ansible and pulls this repo
- **Ansible playbooks** handle all post-install configuration: packages, Docker Compose setup, config files, service enablement, etc.
- Rationale: Shell scripts get imperative and messy; Ansible is declarative, idempotent (safe to re-run), and purpose-built for server provisioning

### Runtime: Docker Compose
- All arr stack apps run as Docker containers managed by docker-compose
- Docker is already installed via the archinstall Server profile
- One compose file per logical group (arr stack, future apps) or a single unified compose

### Arr Stack apps
Core (required):
- **Sonarr** — TV series management
- **Radarr** — Movie management
- **Prowlarr** — Indexer manager (replaces Jackett)

Extras: None (Lidarr, Readarr, Bazarr are out of scope for now)

### Download / File Transfer
- Downloads do **not** happen on this server
- A separate machine handles torrenting; completed files are transferred to loki
- Transfer method TBD (NFS, Samba, rsync over SSH, or Syncthing — decide in Phase 3)
- Arr apps on loki will monitor a local directory where completed files land

### Media Server
- TBD — likely Jellyfin (open source, no account required)
- Decide and document in Phase 5

### Tailscale
- Already in base packages; provides VPN access to the server
- Auth and configuration handled in post-install automation (Phase 2)

---

## Conventions & Constraints

- **Don't be opinionated about Arch defaults** — use whatever Arch/the project recommends (e.g., systemd vs init.d, default service managers)
- **Be opinionated where stated** — decisions recorded above are firm unless explicitly revisited
- All config as code — nothing manual that isn't captured in this repo
- Secrets (passwords, API keys, Tailscale auth key) handled via a secrets approach TBD in Phase 2 (e.g., Ansible Vault, environment file not committed)
- `/dev/sda` is the current disk in config — may need to parameterize if hardware changes

---

## Repo Structure (planned)

```
arrserver/
├── arch/
│   ├── configuration.json      # archinstall OS config
│   └── credentials.json        # archinstall user config
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml           # target hosts (loki)
│   ├── playbooks/
│   │   ├── bootstrap.yml       # first-run: Tailscale, Docker, dirs
│   │   ├── arr.yml             # arr stack deploy
│   │   └── ...
│   ├── roles/                  # reusable Ansible roles
│   └── group_vars/
│       └── all.yml             # shared vars (non-secret)
├── docker/
│   └── compose.yml             # all app containers
├── plan/
│   ├── product.md              # this file (long-term memory)
│   └── phase-*.md              # per-phase working docs
└── README.md                   # quick-start bootstrap command
```

---

## Phase Summaries

### Phase 1 — OS Installation
Goal: Boot from Arch ISO, run one command, reboot into a configured system.

Deliverables:
- `arch/configuration.json` — OS, disk, packages, profile
- `arch/credentials.json` — users
- README bootstrap command

Notes:
- Already well started; `configuration.json` is functional
- Disk is currently hardcoded to `/dev/sda` — acceptable for now

### Phase 2 — Post-Install Bootstrap & Automation
Goal: After first boot, one command gets the machine fully configured.

Deliverables:
- Ansible installed on loki (via shell snippet or `custom_commands`)
- Ansible inventory targeting loki
- Bootstrap playbook: Tailscale auth, Docker daemon config, directory structure, SSH hardening
- Secrets strategy defined (Ansible Vault or `.env` file pattern)

### Phase 3 — File Sharing & Storage Layout
Goal: Completed downloads from the other machine land on loki in the right place.

Deliverables:
- Storage directory structure defined (`/data/media`, `/data/downloads`, etc.)
- File transfer method chosen and configured
- Permissions set correctly for Docker containers (PUID/PGID)

### Phase 4 — Arr Stack
Goal: Sonarr, Radarr, Prowlarr running in Docker Compose, connected to each other and to the file share.

Deliverables:
- `docker/compose.yml` with Sonarr, Radarr, Prowlarr
- Apps configured and talking to each other
- Ansible playbook deploys and manages the stack

### Phase 5 — Media Server
Goal: Browse and stream media from loki.

Deliverables:
- Media server chosen (likely Jellyfin) and added to compose
- Integrated with arr stack library paths

### Phase 6+ — Future Apps
TBD. Extend the Ansible + Docker Compose pattern.
