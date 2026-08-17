# nixcfg

find this repo on radicle:
  * https://radicle.network/nodes/iris.radicle.network/rad:z2EyQm4sTaK1NfEKBYZoiUGF76xvH
  * or: `rad checkout rad:z2EyQm4sTaK1NfEKBYZoiUGF76xvH`

*Nix rules everything around me*

- [nixcfg](#nixcfg)
  - [Overview](#overview)
  - [Components Used](#components-used)
  - [What I Use](#what-i-use)
  - [Repo Layout](#repo-layout)

## Overview

* NixOS configurations for my laptop, and old desktop server
* [**Determinate Nix**](https://docs.determinate.systems/determinate-nix/)-powered
* **reproducible**, and **immutable** *full* system configuration (think **dotfiles**, but better)

## Components Used

* [`home-manager`](https://github.com/nix-community/home-manager) for user-based app/desktop configuration
* [`sops-nix`](https://github.com/Mic92/sops-nix) for secrets (encrypted at rest, per-host encryption)
* [`lanzaboote`](https://github.com/nix-community/lanzaboote) for bootloader configuration
* **[`determinate`](https://github.com/DeterminateSystems/determinate) for getting the best version of Nix with robust defaults**


## What I Use
* `firefox`: because Google should not own the web, and [Sideberry](https://addons.mozilla.org/en-US/firefox/addon/sidebery/) is essential for tree-style tabs
* [`helix`](https://helix-editor.com/): my go-to editor; TUI, Rust, modal, built-in LSP, etc
* [`zelij`](https://zellij.dev/): `tmux` but better, with excellent UX for beginners

## Repo Layout

* `hosts` 
  * toplevel machine definitions:
  * `raisin`
    * **Lenovo "Yoga Slim 7 Pro-14ACH5 Laptop (ideapad) - Type 82MS"**
    * retired laptop
    * SyncThing node
    * Tailscale exit node
* `images/`
  * `installer` (meta, iso)
    * configuration for a custom `x86_64-linux` installer image
    * includes my SSH key and `sshd` enabled and most used programs
    * see: `nix build .#extra.x86_64-linux.installer`
* `misc/`
  * misc scripts
  * buyer beware
* `mixins/`
  * individual application configuration (mostly via `home-manager`)
  * mix of `home-manager` and `nixos` configuration
  * (`prs`, `jj`, `git`, `ssh`, `zsh`, `nushell`, `gnupg`, `helix`, etc)
* `profiles/`
  * bits that compose machine "personas"
  * `core.nix` - core bits, see also `mixins/common.nix`
  * `interactive.nix` - headless systems
  * `gui.nix` - baseline for GUI systems
  * `gui-wayland.nix` - common tools for wayland/wlroots compositors
  * `gui-cosmic.nix` - bare COSMIC configuration (maybe `cosmic-manager` in the future?)
  * `addon-dev.nix` - pull devtool's shell deps into system
  * `addon-laptop.nix` - common laptop bits, power management, etc
  * `addon-asus.nix` - extras for my ASUS laptop
  * `user-cole.nix` - my base `cole` user configuration
* `secrets/`
  * script to manage `sops` for `sops-nix`
* `shells/`
  * nix shells for various scenarios
    * `_minimal.nix` - minimal shell base
    * `ci.nix` - tools needed to drive CI for this repo
    * `devenv.nix` - complete set of tools for Go/Rust/Nix development
    * `uutils.nix` - experimentation with rust-based coreutils
* `main.nu`
  * custom script for builds, deploys, etc
