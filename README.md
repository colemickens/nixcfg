# nixcfg

My NixOS Configuration.

Feel free to open issues if you're curious about anything.

## Layout

- `cloud/` contains scripts/harnesses for building nixos cloud images
- `imports/` static, pinned references for all imports
- `machines/` contains definitions of my machines:
  - `xeep` - Dell XPS 13 9370
  - `slynux` - gaming desktop machine turned quaranine-era development machine
  - `jeffhyper` - defines a HyperV system that runs on my Dad's server
  - `raspberry` - my Raspberry Pi 4 system (Unifi, Home-Assistant, Prometheus, Grafana, Plex-MPV-Shim)
  - `rpikexec/rpiboot` - a WIP project that might be replaced by nixiosk (or whatever it's called)
- `misc/` miscellaneous scripts
- `modules/` various common bits including in machine configs (profiles/package lists/preferences)
- `shells/` some devenv style shells for developing go/rust apps under NixOS

There are some useful scripts at the toplevel:

```bash
# invoke nix-build with my remote builders, trusted binary caches, etc
# (by default ./nixbuild.sh with no args will build all of my machine configs)
./nixbuild.sh

# build and deploy machine config
./nixup.sh ${MACHINE_NAME} ${MACHINE_SSH_IP} ${MACHINE_SSH_PORT}
./nixup.sh raspberry 192.168.1.2 22
./nixup.sh jeffhyper sadiethedog.duckdns.org 22
./nixup.sh slynux localhost 22
./nixup.sh xeep 192.168.1.35 22

# build $(hostname)'s config and activate (without using ssh)
./nixup.sh

# update imports (nixos-hardware, nixpkgs-mozilla, etc)
./update-imports.sh
```

Nixpkgs is specifically controlled, but currently just uses a local path for all machines at the moment. This is due to on-going work on nixpkgs and wanting to use my fork on my machines.

In theory, if you removed nixpkgs-mozilla's firefox package (it's impure/nightly), and pinned nixpkgs, all of my machines are fully reproducible.
