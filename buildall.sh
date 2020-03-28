#!/usr/bin/env bash
set -x
set -euo pipefail

# nix build --print-build-logs \
#   -f default.nix \
#   --builders-use-substitutes \
#   --builders 'ssh://colemickens@aarch64.nixos.community aarch64-linux /home/cole/.ssh/id_ed25519; ssh://cole@azdev.westus2.cloudapp.azure.com x86_64-linux /home/cole/.ssh/id_ed25519' \
#   raspberry

# FUCKING NIX CLI
# OH MY FUCK
# EVERY
# GOD
# DAMN
# TIME

 nix-build default.nix \
   --builders-use-substitutes \
   --builders 'ssh://colemickens@aarch64.nixos.community aarch64-linux /home/cole/.ssh/id_ed25519; ssh://cole@azdev.westus2.cloudapp.azure.com x86_64-linux /home/cole/.ssh/id_ed25519' \
   -A raspberry

# nix-build default.nix \
#   --builders-use-substitutes \
#   --builders 'ssh://cole@192.168.1.2 aarch64-linux /home/cole/.ssh/id_ed25519' \
#   -A raspberry
