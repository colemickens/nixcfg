# colemickens/**nixcfg**

# operation NixOS Challenge
## keep / wipable
## mount /var
## mount /nix
## mount /home

## nixcfg + nixpkgs goes in /home/nix
## regular server storage in /var
## regular cole data in /home/cole


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

