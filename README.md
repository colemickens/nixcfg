# nixcfg
*Nix rules everything around me*

<!--[![builds.sr.ht status](https://builds.sr.ht/~colemickens/nixcfg.svg)](https://builds.sr.ht/~colemickens/nixcfg?)-->

- [Overview](#overview)
- [Repo Layout](#repo-layout)
- [Secrets](#secrets)
- [Other Interesting Nix Repos](#other-interesting-nix-repos)

## Overview

* nix configuration for my laptop~s~, ~desktops~, ~sbcs~, ~phones~, and cloud servers
* **nix flake**-powered
* guaranteed to be **reproducible**
* **immutable** *full* system configuration (**dotfiles**, but on steroids)

## Components

* `home-manager` for user-based app/desktop configuration
* `sops-nix` for secrets (encrypted at rest, per-host encryption)
* custom commands for easy gpg-over-ssh usage (`pkgs/commands.nix`)

## Repo Layout
* `cloud` - contains some scripts/configs for booting NixOS instances in GCP/Azure/Equinix Metal
* `docs` - notes to self
* `hosts` - machine definitions for:
  * `installer` (meta, iso)
    * configuration for a custom installer image with my SSH key and `sshd` enabled
    * see: `nix build .#images.installer`
  * `raisin` (laptop)
    * former-daily-driver
    * **Lenovo "Yoga Slim 7 Pro-14ACH5 Laptop (ideapad) - Type 82MS"**
    * used as a remote (Kansas) ZFS/syncthing backup target
  * `xeep` (laptop)
    * former-former-daily-driver **Dell XPS 9370**
    * used as a remote (Missouri) ZFS/syncthing backup target
  * `zeph`
    * current daily-driver
    * favorite, all-AMD, laptop ever
    * **ASUS Zephyrus G14 (2022) - GA402RJ**
    * dual-booting NixOS, of course, and Windows 11 for casual 120Hz/1600p gaming
* `misc/` - literally just scripts I have no better home for
* `mixins/`
  * individual application configuration lives (mostly via `home-manager`)
  * (`libvirt`, `prs`/`gopass`, `git`, `gnupg`, `spotifyd`, `tailscale`, `wezterm`, etc)
* `pkgs/`
  * my own "packages"
  * custom shell commands (gpg+ssh wrapper, etc)
  * tip-of-tree package overrides for:
    * `wezterm`
    * `nushell`
* `profiles/` - these are the bits that primarily get pulled into a system configuration.
  * `gui.nix` - all of my GUI related settings that only apply to machines that I sit in front of
  * `interactive.nix` - anything related to a machine that I interact with regularly (and thus want `neovim`, etc)
* `secrets/`
  * `sops-nix` based secret management
  * scripts to manage `sops`, sops-nix` is great, `sops` is questionable-code-quality abandonware with odd usage patterns
* `shells/`
  * nix shells for various scenarios
    * `devtools.nix` - tools for my dev machines
    * `ci.nix` - tools needed to drive CI for this repo
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
