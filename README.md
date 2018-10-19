# colemickens/**nixcfg**

This is my nix configuration files for all of my various nix endeavors.

This has a variety of dependenices on various branches of my fork of nixpkgs.
Generally I try to keep the commits I carry light, upstreaming as much as possible.
My primary branch is `cmpkgs`. (As of 2018-10-18, the other in-use or in-progress branches are `sway`, `kata`, `plex`.)

More stuff.
1. `utils/bootstrap/bootstrap.nix` boots a nixos remote vm and switches to `pktkube` config from this repo
2. `utils/bootstrap/bootstrap.sh` ensures `nixcfg` (This repo) is avaiable, and switches into the ptkube new config, AFTER calling `utils/bootstrap/bootstrap-nixpkgs.sh` which bootstraps the pkgs repo
3. `utils/bootstrap/bootstrap-nixpkgs.sh` will **idempotently** ensure that for each branch of my nixpkgs fork, there is a resulting `/etc/nixpkgs-${branch}` directory with the worktree for that branch


Then you'll want to start at:
* `./default.nix` which pulls in the two outputs
* `./output/[device]-toplevel.nix` which pulls in the system config, and the appropriate nixpkgs branch, and builds thetop level configurations.

The other scripts in `utils/` sorta work together in rather specific nixos:

### Nix

* `./nix/update-sway-wlroots.sh` is a script for me that updates `sway`, `wlroots`, `grim`, `slurp` to `HEAD` of their respective repos
* `./nix/cache-closure.sh` creates a compressed NAR for the things in the specified closure at a defined or customizable path

### Azure

* `./azure/upload-cache.sh` uploads the cache created by calls to `cache-closures.sh`. It will list the nar/narinfos in the Azure storage account and uploads the necessary missing (aka, new) files
* `./azure/nix-build.sh` will sorta do a nix-build (TODO) that uses our nix cache. This is useful in case we're not sure our custom nixpkgs config is applied and we want to ensure we can utilize the cache.
* `./azure/btw.sh` will:
   * build everything we know about in `outputs/` (aka, all of our system configs, installers, etc)
   * upload each closure to storage
   * upload current system config to storage for good measure
.
