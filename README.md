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

## Notes

#### Pinned Imports & Code Layout

We have pinned imports for all nix imports. (One semi-exception is that the
pinned nixpkgs-mozilla overlay will still pull down nightly builds.)

However, this is constrictive in the real-world where I'm iterating on my various
nixpkgs branches and want to build my machine configs against them instead of the pinned references.

Solution: `lib.nix` exports a function called `findImport` that will look 
for the same-layed-out and same-named directories according to my local source code organization.

In this example layout, my local copy of nixpkgs at `$HOME/code/nixpkgs/cmpkgs` is used instead of the pinned
`imports/nixpkgs/cmpkgs` in my various machine configs.

```
+ nixcfg/
  |- imports/nixpkgs/cmpkgs/metadata.nix (hard-coded nixpkgs used if local copy is missing)
  |- machines/xeep/default.nix (calls (../../lib.nix).findImport to get `nixpkgs/cmpkgs`)
  |- lib.nix
+ nixpkgs/
  |- cmpkgs/
  |- master/
```

This means that:

1. My configs are reproducible! (except for when my local nixpkgs drifts, but I try to push often!)
2. Things are still flexible enough that this still looks like my normal nixpkgs development workflow
   before trying to reproduce-all-the-things.

#### Scripts

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

## Todo/complaints

The split between `cloud/*` and their `machine/*` counterpart is weird.

But that's partly because all of our azure scripts are upstream, versus our GCP
stuff which will probably just stay local.
