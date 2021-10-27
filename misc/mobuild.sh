#!/usr/bin/env bash

set -euo pipefail
set -x

# it just depends, images need to come to localhost for flashing
# but toplevels should be pulled directly to device

"${DIR}/rbuild.sh" \
  "oldcopy" \
  "activate" \
  "colemickens@aarch64.nixos.community" \
  "colemickens@$(tailscale ip --4 "enchilada")" \
      "~/code/nixcfg#enchilada" \
      --override-input 'mobile-nixos' "~/code/mobile-nixos"
