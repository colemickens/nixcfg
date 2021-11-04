#!/usr/bin/env bash
DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
set -euo pipefail
set -x

# it just depends, images need to come to localhost for flashing
# but toplevels should be pulled directly to device

"${DIR}/rbuild.sh" \
  "oldcopy" \
  "activate" \
  "colemickens@aarch64.nixos.community" \
  "colemickens@$(tailscale ip --4 "enchilada")" \
      "${HOME}/code/nixcfg#toplevels.enchilada" \
      --override-input 'mobile-nixos'  "${HOME}/code/mobile-nixos"
