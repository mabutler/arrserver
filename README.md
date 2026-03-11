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

After reboot, SSH in and run the Ansible bootstrap (Phase 2 — coming soon).

## Planning

See [`plan/product.md`](plan/product.md) for the full project plan.
