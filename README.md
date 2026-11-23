# machine-inventory

Machine-class inventory for the `sakuragaoka-homelab` fleet.

This repository lives in `sakuragaoka-homelab/machine-inventory`. Work happens on a branch
with a pull request into `main`; the merge is a squash merge.
See [the owner standard](https://github.com/sakuragaoka-homelab/.github/blob/main/standards/owner.md)
for the branch model and the protection rules.

## What it does

It records each fleet machine as classes, counts, and buckets: CPU core and
thread counts, a RAM tier, a GPU class, disk counts by class, and capability
flags. It is public, so it never records a value that identifies a machine or a
person. There is no hostname, username, serial, IP, or drive path in a record.

## Quick start

```bash
just install
just verify
```

## Machines

<!-- machines:start -->
| Machine | Role | Storage | OS | CPU | RAM | GPU | Disks | Always on | Local inference |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| desktop-primary | workstation | storage-ample | windows Windows 11 26H2; wsl Ubuntu 26.04.1 LTS | 24c/32t | 32-63 | discrete | hdd 3, nvme 1 | no | llama.cpp b11529; CUDA 12.4; Qwen3.5-9B UD-Q4_K_XL; 16 GB VRAM; loopback:18080; Pi/llama-local |
<!-- machines:end -->

## Commands

| Command             | Does                                                     |
| ------------------- | -------------------------------------------------------- |
| `just install`      | Installs the pinned tools.                               |
| `just lint`         | Runs the linters and workflow checks.                    |
| `just render`       | Rewrites the machine table above from `machines/*.json`. |
| `just render-check` | Fails when the machine table is stale.                   |
| `just collect`      | Collects a machine record on Windows.                    |
| `just test`         | Validates the records and the rendered table.            |
| `just verify`       | Runs `just check` and `just test`.                       |

## Documentation

Read [`docs/README.md`](docs/README.md).

## License

MIT. See [`LICENSE`](LICENSE).

## Related repositories

- [the owner standard](https://github.com/sakuragaoka-homelab/.github/blob/main/standards/owner.md) defines the shared workflow, checks and toolchain.
