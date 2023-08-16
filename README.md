# nixcfg
*Nix rules everything around me*

<!--[![builds.sr.ht status](https://builds.sr.ht/~colemickens/nixcfg.svg)](https://builds.sr.ht/~colemickens/nixcfg?)-->

- [Overview](#overview)
- [Components](#components)
- [Repo Layout](#repo-layout)
- [Secrets](#secrets)
- [Other Interesting Nix Repos](#other-interesting-nix-repos)

## Overview

* nix configuration for my laptop~s~, ~desktops~, ~sbcs~, ~phones~, and cloud servers
* **nix flake**-powered
* guaranteed to be **reproducible**
* **immutable** *full* system configuration (**dotfiles**, but on steroids)

#### notes

* some commits may have empty commit messages, this is from me attempting to
  use and learn [`jj`](https://github.com/martinvonz/jj).

## Components

* `home-manager` for user-based app/desktop configuration
* `sops-nix` for secrets (encrypted at rest, per-host encryption)
* `terranix` for cloud server creation/deletion automation
* custom commands for easy gpg-over-ssh usage (`pkgs/commands.nix`)

## Repo Layout

(this sometimes drifts, but should be roughly accurate as of April 2023)

* `cloud`
  * automation and configuration for cloud servers
  * powered by `terranix`
* `docs`
  * notes to self
  * who knows what "great" ideas and tidbits it contains
* `hosts` 
  * toplevel machine definitions
  * `openstick`
    * configuration for a $10USD LTE USB Modem Stick
  * `installer` (meta, iso)
    * configuration for a custom `x86_64-linux` installer image
    * includes my SSH key and `sshd` enabled and most used programs
    * see: `nix build .#images.installer`
  * `raisin` (laptop)
    * former-daily-driver
    * **Lenovo "Yoga Slim 7 Pro-14ACH5 Laptop (ideapad) - Type 82MS"**
    * remote (KS, USA) `zrepl`(`zfs`) and `syncthing` backup target
  * `xeep` (laptop)
    * former-former-daily-driver **Dell XPS 9370**
    * remote (MO, USA) `zrepl`(`zfs`) and `syncthing` backup target
  * `zeph` (laptop)
    * current daily-driver
    * favorite, all-AMD, laptop ever
    * **ASUS Zephyrus G14 (2022) - GA402RJ**
    * dual-booting NixOS, of course, and Windows 11 for casual 120Hz/1600p gaming
* `misc/`
  * misc scripts
  * buyer beware
* `mixins/`
  * individual application configuration (mostly via `home-manager`)
  * (`libvirt`, `prs`/`gopass`, `git`, `gnupg`, `spotifyd`, `tailscale`, `wezterm`, etc)
* `pkgs/`
  * my own "packages"
  * custom shell commands (gpg+ssh wrapper, etc)
  * tip-of-tree package overrides for:
    * `wezterm`
    * `nushell`
* `profiles/`
  * bits that compose machine "personas"
  * `core.nix` - core bits, see also `mixins/common.nix`
  * `interactive.nix` - headless systems
  * `gui.nix` - baseline for GUI systems
  * `gui-wayland.nix` - common tools for wayland/wlroots compositors
  * `gui-sway.nix` - the start of my `sway` GUI configuration
  * `addon-dev.nix` - pull devtool's shell deps into system
  * `addon-laptop.nix` - common laptop bits, power management, etc
  * `addon-asus.nix` - extras for my ASUS laptop
  * `user-cole.nix` - my base `cole` user configuration
* `secrets/`
  * scripts to manage `sops` for `sops-nix`
  * `sops-nix` is great... but...
  * `sops` is questionable-code-quality near-abandonware
* `shells/`
  * nix shells for various scenarios
    * `_minimal.nix` - minimal shell base
    * `ci.nix` - tools needed to drive CI for this repo
    * `devenv.nix` - complete set of tools for Go/Rust/Nix development
    * `devtools.nix` - bare-essential dev tools for my dev machines
    * `gstreamer.nix` - old, for tinkering with rust+gstreamer stuff
    * `uutils.nix` - experimentation with rust-based coreutils
* `main.nu`
  * a homegrown `nushell` (❤️) script for managing this repo
  * updates/rebases my flake inputs
  * updates/rebases my custom packages to tip-of-branch
  * updates the lock file

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
