#!/usr/bin/env bash
set -x
set -euo pipefail

nix build -L \
  -f default.nix \
  --builders-use-substitutes \
  --builders 'ssh-ng://colemickens@aarch64.nixos.community aarch64-linux /home/cole/.ssh/id_ed25519; ssh-ng://cole@azdev.westus2.cloudapp.azure.com x86_64-linux /home/cole/.ssh/id_ed25519' \
  rpiboot
