# Pre-Bare-Metal Checklist

Tasks to complete before running on real hardware.

---

- [ ] Retrieve OS SSD `/dev/disk/by-id/` path from live environment (`ls -la /dev/disk/by-id/`)
- [ ] Update `arch/configuration.json` disk reference to use by-id path
