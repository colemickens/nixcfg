# nixcfg
*Nix rules everything around me*

<!--[![builds.sr.ht status](https://builds.sr.ht/~colemickens/nixcfg.svg)](https://builds.sr.ht/~colemickens/nixcfg?)-->

## Overview

* nix configuration for my laptops, desktops, phone, and cloud servers - **all of my devices**
* **nix flake**-powered
* guaranteed to be **reproducible**
* all of my **dotfiles**

**Note**: this readme assumes [you have enabled nixUnstable + flakes](https://www.tweag.io/blog/2020-07-31-nixos-flakes/).

- [Overview](#overview)
- [Disclaimer](#disclaimer)
- [Repo Layout](#repo-layout)
- [Custom Packages](#custom-packages)
- [Dotfiles](#dotfiles)
- [Secrets](#secrets)
- [Interesting Tidbits](#interesting-tidbits)
- [Other Interesting Nix Repos](#other-interesting-nix-repos)

## Disclaimer

This is not the best NixOS config repo to start from, if you are starting out and trying to build your own configuration.
For example, [`nixflk`](https://github.com/nrdxp/nixflk) provides a flake repo that is more thoughtfully laid out, and that does a better job of
organizing configuration in a proper layered way.

In this repo, I *freely combine NixOS and Home-Manager configuration* via my "mixins" and "profiles". For a while, they
were layered and separatedly "nicely", but there are a number of things that fundemtanlly *require being configured in tandem*
and I prefer having the relevant config side-by-side in a single "mixin" file, rather than in two distinct places for the sake
of "layering".

Howevever, the layered approach feels more rigorous and more appropriate to recommend for others starting out.
This layered approach also makes it easier to re-use the Home-Manager configuration on a non-NixOS system. (Though,
I suspect you can still build my home-manager module individually to get the same config.)

## Repo Layout
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


## Custom Packages

I package these things, mostly for myself:

- cchat-gtk (a new GTK chat client supporting, so far, **Discord**!)
- obs-v4l2sink (my fork of obs-v4l2sink)
- mirage-im (an Qt5 Matrix client)
- neovim (nightly 0.5 build for LSP support)
- passrs (a Rust pass implementation, not actually using though)
- raspberrypi-eeprom (the rpi4 boot eeprom files)
- rpi4-uefi (a rpi4 uefi build)

Many of these are building latest from the tip of their development branches,
using an auto-update script that is also used in `nixpkgs-wayland`.

These are easily runnable, if you [have enabled Nix flakes](https://discourse.nixos.org/t/using-experimental-nix-features-in-nixos-and-when-they-will-land-in-stable/7401/4):

```shell
nix shell "github:colemickens/nixcfg#cchat-gtk" --command cchat-gtk
```


## Dotfiles

Interspersed in my configuration is `home-manager` configuration. Home Manager modules
produce config files in the Nix store which are then symlinked into place in your home directory.
This means that my dotfiles are entirely managed as part of my system configuration:

Some examples:

- `gpg-agent` config: https://github.com/colemickens/nixcfg/blob/main/mixins/gpg-agent.nix
- `sway`: https://github.com/colemickens/nixcfg/blob/main/mixins/sway.nix
- `neovim` config + pinned plugins: https://github.com/colemickens/nixcfg/blob/main/mixins/neovim.nix
- `obs-studio` config + pinned plugins: https://github.com/colemickens/nixcfg/blob/main/mixins/obs.nix

If you think converting config to Nix is overkill, you can also include the raw config files and instruct
Home-Manager to symlink them into place.

## Secrets

Secrets are all stored encrypted with `sops` (via `sops-nix`) so that they remain encrypted at rest in the Nix store.

## Interesting Tidbits

(TODO: note to self, remove this section, turn it into a blog post, or series)

* Everything builds in Nix, with Flakes (meaning Pure mode). This necessitated the  creation of `colemickens/flake-firefox-nightly`.
* Nix lets you do silly things like The terminal colors and fonts for all of my terminal emulators are declared in Nix. I can change the appearance of all of them uniformly, in one place. (https://github.com/colemickens/nixcfg/blob/main/mixins/_common/termsettings.nix)
* home-assistant config
* unifi
* sops for secrets stored in-tree
* auto-update script for ./pkgs/ that keep everything building from their tips-of-trees

## Other Interesting Nix Repos

- jtojnar: https://github.com/jtojnar/nixfiles
  - particularly of note:
    - use of NixGL to use GUI apps built with Nix on other Linuxes:
      https://github.com/jtojnar/nixfiles/blob/522466da4dd5206c7b444ba92c8d387eedf32a22/hosts/brian/profile.nix#L10-L12
- Mic92: https://github.com/Mic92/dotfiles
  - in particular:
    - https://github.com/Mic92/dotfiles/tree/master/nixos/images
      - kexec stuff is neat
      - base-config does a Hidden Service + announces over IRC, very cool
- cole-h: https://github.com/cole-h/nixos-config
- bqv: https://github.com/bqv/nixos
- nixos-org-configurations:
  - in particular:
    - configs for building NixOS images containing MacOS VM guests
      - https://github.com/NixOS/nixos-org-configurations/tree/master/macs/host
