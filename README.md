# nixcfg
*Nix rules everything around me*

<!--[![builds.sr.ht status](https://builds.sr.ht/~colemickens/nixcfg.svg)](https://builds.sr.ht/~colemickens/nixcfg?)-->

## Overview

It's everything. It's all of my system configurations. It's all of my dotfiles. All right here. All in Nix.

## Custom Packages

I package these things, mostly for myself:

- cchat-gtk (a new GTK chat client supporting, so far, **Discord**!)
- obs-v4l2sink (my fork of obs-v4l2sink)
- mirage-im (an Qt5 Matrix client)
- neovim (nightly 0.5 build for LSP support)
- passrs (a Rust pass implementation, not actually using though)
- raspberrypi-eeprom (the rpi4 boot eeprom files)
- rpi4-uefi (a rpi4 uefi build)

These are easily runnable, if you [have enabled Nix flakes]():

```shell
# if you have not enabled flakes globally, and have not cloned this repo,
# you can still run these!

nix --experimental-features 'nix-command flakes' \
  shell "github:colemickens/nixcfg#cchat-gtk" --command cchat-gtk

# or if you have configured Nix to enable flakes system-wide,
# and you've cloned this repo:

nix shell ".#neovim" --command nvim
nix shell ".#passrs" --command passrs
```

## Layout
* `cloud` - contains some scripts/configs for booting NixOS instances in GCP/Azure
* `hosts` - machine definitions for:
  * `azdev` - an Azure dev env machine
  * `pinebook` - my current daily-driver laptop (Pinebook Pro, aarch64)
  * `pinephone` - my future daily-driver phone (Pinephone Pro, via NixOS Mobile, aarch64)
  * `pixel` - a defunct attempt at porting NixOS Mobile to `bluecross` (Pixel 3)
  * `rpione` - the brain of my house
    * Home-Assistant with my custom config + Lovelace layouts, etc.
    * Unifi Controller (on demand, to relieve memory usage)
    * Tor Hidden Service (for _reliable_ permanent remote-access into my network)
    * (WIP) a netboot server for `rpitwo`
  * `rpitwo` - a WIP attempt at fully netbooting an UEFI-powered RPI4 with NixOS over NFS
  * `slynux` - this is my gaming-machine turns quarantine-dev-machine. This runs natively on my gaming machine, or as a hyperV VM when the host is running Windows **(Very Useful!)**
  * `winvm` - an example Windows VM built with Nix, via the awesome `wfvm` project
  * `xeep` - my old, dead XPS 13 (9370) laptop
* `misc/` - literally just a script I have no better home for
* `mixins/` - this is where all of the important parts of system/dotfile config lives
  * this is where `sway`, `redshift`, etc type config lives
  * this is also where `docker`, `libvirt`, etc are configured
* `packages`/ - nix packages that I maintain local to this repo, they don't belong in nixpkgs (yet)
* `profiles/` - these are the bits that primarily get pulled into a system configuration.
  * `gui.nix` - all of my GUI related settings that only apply to machines that I sit in front of
  * `interactive.nix` - anything related to a machine that I interact with regularly (and thus want `neovim`, etc)
* `secrets/` - some light infra around `sops-nix` for dealing with encrypted secrets in this repo and my systems
* `shells/` - a few `shell.nix`s for being able to hack on random source code trees


## Dotfiles

As examples:

- GPG-Agent config: https://github.com/colemickens/nixcfg/blob/main/mixins/gpg-agent.nix
- Sway: https://github.com/colemickens/nixcfg/blob/main/mixins/sway.nix
- Neovim, and plugins: https://github.com/colemickens/nixcfg/blob/main/mixins/neovim.nix
- OBS and plugins: https://github.com/colemickens/nixcfg/blob/main/mixins/obs.nix

## Secrets

Secrets are all stored encrypted with `sops` (via `sops-nix`) so that they remain encrypted at rest in the Nix store.

## Highlights

* Everything builds in Nix, with Flakes (meaning Pure mode). This necessitated the  creation of `colemickens/flake-firefox-nightly`.
* The terminal colors and fonts for all of my terminal emulators are declared in Nix. I can change the appearance of all of them uniformly, in one place. (https://github.com/colemickens/nixcfg/blob/main/mixins/_common/termsettings.nix)
