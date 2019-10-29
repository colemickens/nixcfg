# nixcfg


TODO: turn aznew.nix into something that can be used with an existing blank image
   - or can be used to press a flat VHD that can be uploaded and used

   - make GCE image? (free BW in, free BW to google drive)
   - then I only pay BW to download and watch, or 2x for Azure to transcode

NixOS Configuration for Cole Mickens's machines.

This repository is used for reproducably\* building the entirety of my computing existence. This includes my laptop, Azure VM, and any containers I happen to be using.

\* = not my phone ([yet](nixos-mobile))
\* = my usage of nixpkgs-mozilla's firefox-nightly attribute is impure

## Layout

* `machines/` contains definitions of my machines:
  * `azdevbox.nix` defines my Azure dev machine
  * `azplexbox.nix` defines my Azure Plex server
  * `azmedia.nix` defines my Azure media download server
  * `xeep-base.nix` defines most of the configuration of my `xeep` laptop (a Dell XPS 13 (9370))
  * `xeep-plasma.nix` defines a `xeep` variant that runs Plasma
  * `xeep-gnomeshell.nix` defines a `xeep` variant that runs Gnome-Shell
  * `xeep-sway.nix` defines a `xeep` variant that runs Sway
  * `packet/` includes a script to bootstrap a Packet VM to build my machine config.


### Reproducability

The machine images and configurations are build using a function declared in `lib.nix` that requires `nixpkgs` be passed as an input. In many cases, for myself, this is an impure reference to my own local copy of `nixpkgs`, but more ideally, it can also be a specific pinned revision of nixpkgs.

In fact, the repo also comes with an `update.sh` that updates pointer references to the latest `nixos-unstable` release.

#### Pinning `nixpkgs`

This repository is explicitly built to work with a pinned nixpkgs. The build and activation scripts explicitly unset `NIX_PATH`. However, the configuration that I build most often is configured to read from `../nixpkgs` so that I can iterate and test with a custom `nixpkgs`, since I am frequently tweaking things, bumping versions, etc and want to be able to send upstream PRs.

The (possibly overly verbose) magic for this is stored in `./lib.nix`. Do be warned, this uses IFD and results in a copy of nixpkgs winding up in your store. For me, this is a small price to pay.

### Details

#### Azure Images

The Azure images rely on a fair amount of work that I pushed upstream to `nixpkgs`. In fact, this work can easily be leveraged to build custom images, replicate them around Azure regions, and boot VMs around the world rather quickly and reliably. It also specifically allows pinning `nixpkgs`.


#### Packet VM

`machines/packet/` contains a script and a templated nix expression. The script will interpolate a Cachix credential file, and Packet credentials into the configuration.

I use this directory in tandem with my `packet-utils` repository. I simply execute: `{packet-utils}/q-create-nixos.sh`  which calls `gen-bootstrap.sh` to perform interpolation, and then calls other scripts in that repo to boot a Packet Spot VM.

If you look inside `packet/bootstrap.in.nix`, you'll quickly see that the VM has a single purpose - to clone my Nix repos, build my system configuration, push it to Cachix, and then destroy itself (via the Packet API).

Altogether, this allows me to rev my nixpkgs, call this script, wait, and then switch my configuration. This is powerful because I can modify dependencies like `mesa`, triggering a rebuild of nearly all GUI related packages on my system, without needing to build everything locally. With the low prices of some Packet Spot VMs, this is quite a nice solution while still allowing me to tweak low-level system dependencies, or try out unreleased versions of software.

## TODO

* Try with --pure again?
* See if nixos-generators has anything interesting, though I still think I have a good solution that respect nixpkg configuration changes from inside the configuration (read: overlays), unlike other solutions I've seen.

 * prototype what this looks like when using Flakes
