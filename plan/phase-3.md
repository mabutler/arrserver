# Phase 3 — Storage Layout & File Sharing

> Medium-term working doc for Phase 3.
> Reference `product.md` for decisions already made.

## Status

**SKIPPED — requires bare metal hardware.**

Come back to this phase once the physical machine is available. The data and parity drive UUIDs need to be collected from the real hardware before any of this can be implemented or tested.

---

## TODO (do before starting this phase)

- [ ] Boot bare metal, collect UUIDs for all 4 drives (`lsblk -f` or `blkid`)
- [ ] Record UUIDs in `ansible/group_vars/all.yml` under `storage_drives`
- [ ] Decide on file transfer method: NFS, Samba, rsync over SSH, or Syncthing
- [ ] Decide on directory structure within the mergerfs pool (movies, tv, etc.)
- [ ] Decide on PUID/PGID for Docker container permissions

---

## Goal

Data drives mounted and pooled; completed downloads land on loki in the right place.

## Planned deliverables

- mergerfs pool across 3 data drives, snapraid parity configured
- Drives referenced by UUID in Ansible vars (never by `/dev/sdX`)
- Storage directory structure defined under `/data/media`
- File transfer method chosen and configured
- Permissions set correctly for Docker containers (PUID/PGID)
