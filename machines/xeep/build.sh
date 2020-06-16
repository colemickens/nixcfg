#!/usr/bin/env bash

nix-shell \
  -I nixpkgs=channel:nixos-unstable \
  -p nixFlakes \
  --command "nix build --experimental-features 'nix-command flakes'"


# notes:
# - flexible inputs?
# - git add ?everything? what if I don't... use git?



