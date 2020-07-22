# nixcfg

[![builds.sr.ht status](https://builds.sr.ht/~colemickens/nixcfg.svg)](https://builds.sr.ht/~colemickens/nixcfg?)

My NixOS + Home-Manager configuration. Think of this as a system-level superset of a dotfiles repo.

This configuration:
 * contains all of my system and application config (except Firefox)
 * is fully reproducible (all imports are pinned; refs are updated with `update.sh`)
 * does not rely on `NIX_PATH`, `nixos-config`, and actually disables `nix.nixPath`
 * avoids `nixos-rebuild`, builds the system config as a normal user
 * allows local clones of imports to override pinned imports for great nixpkgs/overlay hacking experience
 * trivially supports building and deploying my remote systems (cloud VMs, raspberry pis, etc)
   * currently:
     * `xeep` (XPS 13)
     * `slynux` (custom gaming pc, moonlighting as non-coil whining dev machine)
     * `raspberry` (creatively-named rpi4 running `unifi` + `home-assistant`)
     * `azdev` (azure cloud dev machine, interactive or remote nix builder)


_**Please**, feel free to open issues if you're curious about anything._

## Layout

The current inspiration for my layout is embracing the divide between 

- `config-homemanager/` - all my user-related config + my modules (*`sway`, `tmux`, `neovim`... configs are here*)
- `config-nixos/` - all my system-related config + my modules
- `imports/` static, pinned references for all imports
- `machines/` - definitions of my machines
- `misc/` - miscellaneous scripts
- `modules/` - various common bits including in machine configs (profiles/package lists/preferences)
- `shells/` - some devenv style shells for developing go/rust apps under NixOS

## Notes

#### Guiding Principals

* Multi-user UNIX systems are inpractical, don't try too hard to optimize for it
* That having been said, Home-Manager makes it easier to be disciplined about it
* Everything is declarative
* Everything is pinned (except `firefox-nightly` due to `nixpkgs-mozilla`)
* Everything is reproducible (again, excepting the differences up
  the tree due to `firefox-nightly`)

#### Look ma, no channels!

My Nix usage involves NO channels. I do not use any of the NixOS channel infrastructure,
other than the fact that I rebase my nixpkgs branch on the `nixos-unstable` branch/channel
to take advantage of Hydra cache hits for store outputs.

While the Nix Flakes proposal would solve additional problems, this allows me to at least get fully
reproducible results. My default my system is built against a pinned nixpkgs, and all imports are pinned
as well. I have to opt-in to updates to these imports, and they're reflected in the git history.

The pieces required for this become more clear after reading the next section, and generally by
following `./default.nix` down the rabbit hole.

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


## Flakes

- my system is now buildable with either flakes or non-flakes
- lib.nix is unneeded
- should build same as non-flake (small diffs due to HM

Both `flake` and `legacy` builds are supported via:

  ```nix
    findImport = (import ../../../lib.nix).findImport;
    mozillaImport = (
      if (builtins.hasAttr "getFlake" builtins)
      then import inputs.mozilla
      else import "${findImport "overlays/nixpkgs-mozilla"}"
    );
  ```

`findImport` was part of my existing pinning system described above.

```bash
$ nixup flake # builds system with flake
$ nixup legacy # builds system with flake
$ nixup flake switch # builds system (flake) then switches to it
$ nixup legacy switch # builds system (legacy) then switches to it

# nix-instantiates the machine, nix copy to a dir, rsync to server build, cachix
$ nixup remote machine_name user@remote_builder

#
$ nixup deploy machine_name user@machine_ip
```

#### Flakes Feedback

TODO: consolidate here
# TODO: I wish outputs were restricted to a "outputs" attribute

- if we're restricted to single derivation output then why not output path at the end?
- don't do this restriction ,or allow a way around it
- the auto-name-coercion is confusin


## Flakes

Some commands that might be useful (notes to self):

```shell
armbuilder="ssh-ng://colemickens@..."
nix build --experimental-features 'nix-command flakes' \
  --builders "${armbuilder} aarch64-linux" \
    '.#nixosConfigurations.raspberry.config.system.build.toplevel'
```