# colemickens/**nixcfg**

# operation NixOS Challenge
## keep / wipable
## mount /var
## mount /nix
## mount /home

# TODO: document this
# nix-path less


## nixcfg + nixpkgs goes in /home/nix
## regular server storage in /var
## regular cole data in /home/cole


# Examples of:
- static, reproducible/repeatable builds for everything
- hyperv vhd image
- system configs
- multi-system installer image

This is my nix configuration files for all of my various nix endeavors.

It also includes scripts to work with my Azure cache.

* `./default.nix` defines our outputs to be built with specific `nixpkgs`. The rabbit hole begins here.
* `./all.sh`:
   * build and upload all outputs via `build.nix`
   * build and upload the `nix-overlay-sway` overlay outputs
   * build and upload `/run/current-system`  to storage for good measure
* `./utils/bootstrap/bootstrap.nix` boots a nixos remote vm and switches to `pktkube` config from this repo
* `./utils/bootstrap/bootstrap.sh` ensures `nixcfg` (This repo) is avaiable, and switches into the ptkube new config, AFTER calling `utils/bootstrap/bootstrap-nixpkgs.sh` which bootstraps the pkgs repo
* `./utils/bootstrap/bootstrap-nixpkgs.sh` will ensure an `/etc/nixpkgs-${branch}` git worktree exists for each branch from our origin
* `./utils/azure/nix-copy-azure.sh <INSTALLABLES>...` uploads the specified installables to an Azure storage container, after copying it to a local staging dir to compress and sign.
* `./utils/azure/nix-build-azure.sh <BUILDABLES>...` will build all buildables using our Azure-backed storage for an extra binary cache

You can figure out the rest by following the rabbit-hole down `./default.nix`.


## NOTES:

1. `lib.overlay` so that we can use overlays directly from git or via a local path if we have ti checked out to work on
s

## TODO:

1. Example of a self-expanding image. (we could make the squashfs, dd, extract, expand luks, expand btrfs operation?)
2. Pre-encrypted image? (dare we store a LUKS passphrase in gopass? thus allowing automation on a trusted machine with a yubikey or gpgagent forwarded)
3. ??
4. non-btrfs? :( not sure I'm willing to bother with ZFS

```bash
export NIX_PATH=nixpkgs=/home/cole/code/nixpkgs:nixos-config=/home/cole/code/nixcfg/machines/xeep.nix
```