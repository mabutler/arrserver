# Phase 1 — OS Installation

> Medium-term working doc for Phase 1.
> Reference `product.md` for decisions already made.

## Goal
Boot from Arch ISO, run one command, reboot into a configured base system ready for Phase 2.

## Status: In Progress

---

## Tasks

- [ ] Trim `configuration.json` packages to bootstrap-minimum
- [ ] Update bare metal disk reference to `/dev/disk/by-id/` (need SSD ID from live environment)
- [ ] Create `configuration.vm.json` for VM testing
- [ ] Update README with bare metal and VM bootstrap commands
- [ ] Validate VM install end-to-end

---

## Blockers

### OS SSD by-id path unknown
The bare metal config needs the SSD's stable identifier. To get it, boot the target machine into any live Linux environment (Arch ISO works) and run:

```bash
ls -la /dev/disk/by-id/
```

Pick the entry that corresponds to the OS SSD (not a partition — the base device). It will look something like:
`ata-Samsung_SSD_870_EVO_250GB_XXXXXXXX` or `nvme-WDS100T1X0E-00AFY0_XXXXXXXX`

Paste the result and we'll update `configuration.json`.

---

## Changes to make

### configuration.json
1. **Packages**: trim to `["git", "curl"]`
2. **Disk device**: change `/dev/sda` to full `/dev/disk/by-id/<id>` path (blocked on above)

### configuration.vm.json (new)
Same as `configuration.json` but:
- Disk device: `/dev/vda` (QEMU/KVM) — can test with `/dev/sda` too if needed
- Hostname: `loki-vm` (optional, avoids conflicts if bare metal is also running)

### README
Add two commands:
- **Bare metal**: `archinstall --config-url .../configuration.json --creds-url .../credentials.json --silent`
- **VM**: `archinstall --config-url .../configuration.vm.json --creds-url .../credentials.json --silent`

---

## Notes
- `credentials.json` is shared between bare metal and VM — no changes needed
- The `custom_commands` field in configuration.json is currently empty — Phase 2 may use this to auto-run the Ansible bootstrap on first boot
- archinstall profile (Cockpit, Docker, sshd) stays as-is — these are correct for both targets
