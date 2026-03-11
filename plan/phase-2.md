# Phase 2 — Post-Install Bootstrap & Automation

> Medium-term working doc for Phase 2.
> Reference `product.md` for decisions already made.

## Goal
After first boot, SSH in and run one command. Ansible takes it from there — packages, Tailscale, Docker config, directory scaffold, SSH hardening.

## Design

### Bootstrap flow
```
First boot
  → SSH in as mbutler
  → Run: bash <(curl -s https://raw.githubusercontent.com/mabutler/arrserver/refs/heads/main/scripts/bootstrap.sh)
  → Script: installs ansible + git, clones repo, runs playbook
  → Playbook: packages, Tailscale, Docker, dirs, SSH hardening
  → Done
```

### Secrets
A `secrets.yml` file lives on the machine but is never committed. An example file is committed to show the structure.

Before running bootstrap, copy and fill in the example:
```bash
cp /opt/arrserver/ansible/secrets.yml.example /opt/arrserver/ansible/secrets.yml
vim /opt/arrserver/ansible/secrets.yml
```

Required secrets:
- `tailscale_auth_key` — from Tailscale admin console (Settings → Keys → Auth Keys)

### Playbook tasks
1. Install packages: `zsh`, `tmux`, `vim`, `rsync`, `smartmontools`, `tailscale`, `base-devel`
2. Set default shell to zsh for mbutler
3. Enable + start tailscaled service
4. Authenticate Tailscale with auth key
5. Create base directory structure (`/data`, `/data/media`, `/data/downloads`)
6. SSH hardening (disable root login — password auth left enabled for now)

### Directory structure (scaffold only — Phase 3 fills it in)
```
/data/
├── media/          # mergerfs mount point (Phase 3)
└── downloads/      # completed download landing zone (Phase 3)
```

---

## Notes
- Ansible runs locally on loki (`--connection=local`), not from a remote machine
- `mbutler` has sudo — playbook uses `become: true`; may need `--ask-become-pass` if sudo requires password
- Docker daemon has no custom config for now — Phase 4 will add compose files
- Tailscale auth key should be a reusable key (or one-off — your call) from the Tailscale admin console
