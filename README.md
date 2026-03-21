# arrserver

Automated Arch Linux setup for a home media server (arr stack + mergerfs/snapraid).

## Bootstrap

Boot from the Arch ISO, then run one of the following:

**Bare metal:**
```bash
archinstall --config-url https://raw.githubusercontent.com/mabutler/arrserver/refs/heads/main/arch/configuration.json --creds-url https://raw.githubusercontent.com/mabutler/arrserver/refs/heads/main/arch/credentials.json --silent
```

**VM (QEMU/KVM):**
```bash
archinstall --config-url https://raw.githubusercontent.com/mabutler/arrserver/refs/heads/main/arch/configuration.vm.json --creds-url https://raw.githubusercontent.com/mabutler/arrserver/refs/heads/main/arch/credentials.json --silent
```

Default user password is `password` — change it after first boot.

## Post-install

After reboot, SSH in as `mbutler` and run:

```bash
git clone https://github.com/mabutler/arrserver /opt/arrserver && sudo bash /opt/arrserver/scripts/bootstrap.sh
```

You will be prompted for:
- **Tailscale auth key** — from the Tailscale admin console (Settings → Keys → Auth Keys)
- **Remote server password** — used once to install the SSH key via `ssh-copy-id`; not stored anywhere

Before running bootstrap, fill in the placeholder values in `ansible/inventory/group_vars/all.yml`:

| Var | Description |
|-----|-------------|
| `sync_remote_host` | IP or hostname of the remote download server |
| `sync_remote_user` | SSH user on the remote server |
| `sync_remote_watch_dir` | Directory qBittorrent watches for `.torrent` files |
| `sync_remote_downloads_dir` | Directory qBittorrent puts completed downloads |

## Storage setup

After bootstrap, run the storage playbook to mount data drives and configure mergerfs/snapraid:

```bash
ansible-playbook /opt/arrserver/ansible/playbooks/storage.yml \
  -i /opt/arrserver/ansible/inventory/hosts.yml \
  --ask-become-pass
```

Then run the initial snapraid sync (builds parity — takes a while):

```bash
sudo snapraid sync
```

## File transfer setup

Run the sync playbook to configure the torrent push/pull timers:

```bash
ansible-playbook /opt/arrserver/ansible/playbooks/sync.yml \
  -i /opt/arrserver/ansible/inventory/hosts.yml \
  --ask-become-pass
```

## Manual configuration (UIs)

These steps must be done in the app UIs after the stack is running:

**Prowlarr** (`loki:9696`)
- Add indexers

**Sonarr** (`loki:8989`)
- Settings → Indexers → Add Prowlarr
- Settings → Download Clients → Add qBittorrent (remote server)
- Settings → Media Management → Root folder → `/data/media/tv`
- Settings → Media Management → Set import mode to **Hardlink**

**Radarr** (`loki:7878`)
- Settings → Indexers → Add Prowlarr
- Settings → Download Clients → Add qBittorrent (remote server)
- Settings → Media Management → Root folder → `/data/media/movies`
- Settings → Media Management → Set import mode to **Hardlink**

**Jellyfin** (`loki:8096`)
- Complete the setup wizard (navigate to `http://loki:8096/web/index.html#!/wizardstart.html` if redirected to server select)
- Add Movies library → `/data/media/movies`
- Add TV Shows library → `/data/media/tv`

**Homarr** (`loki:7575`)
- Add tiles for all services

## Pruning downloads

When finished with a download:
1. Remove torrent from qBittorrent (use "remove + delete data") — stops seeding and deletes remote data
2. Delete the `.torrent` file from local `/data/torrents`
3. Delete the data from local `/data/downloads`

## Planning

See [`plan/product.md`](plan/product.md) for the full project plan.
