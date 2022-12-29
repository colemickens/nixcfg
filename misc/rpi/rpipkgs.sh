#!/usr/bin/env bash
set -x
set -euo pipefail

upstream="nixos/nixos-unstable-small"

    # make sure cmpkgs is already rebased
    (d="${HOME}/code/nixpkgs/cmpkgs"; cd "${d}" \
      && git -C "${d}" remote update \
      && git -C "${d}" rebase "${upstream}")

    # now update-rpi-packages.sh
    # this will rebase itself on its known upstream and wip branch
    (d="${HOME}/code/nixcfg/misc/rpi"; cd "${d}" \
      && ./update-rpi-packages.sh)
      
    # now that we're done, we can reset our 'rpi-wip' to the updated
    # one, just assuming the update was good
    (d="${HOME}/code/nixpkgs/rpi-wip"; cd "${d}" \
      && git -C "${d}" reset --hard rpi-updates-auto)
    
    # and now take our custom cmpkgs-rpipkgs and rebase on cmpkgs again
    (d="${HOME}/code/nixpkgs/cmpkgs-rpipkgs"; cd "${d}" \
      && git -C "${d}" reset --hard rpi-updates-auto \
      && git -C "${d}" rebase cmpkgs \
      && git -C "${d}" push origin HEAD -f)

    # some internal tow-boot upkeep
    (d="${HOME}/code/tow-boot/development"; cd "${d}" \
      && git -C "${d}" remote update \
      && git -C "${d}" reset --hard 'tow-boot/development')
    (d="${HOME}/code/tow-boot/rpi"; cd "${d}" \
      && git -C "${d}" commit . -m "wip: $(date '+%F %T')" || true \
      && git -C "${d}" rebase 'development' \
      && nix flake lock --recreate-lock-file --commit-lock-file \
      && git -C "${d}" push origin HEAD -f)
    (d="${HOME}/code/tow-boot/radxa-zero"; cd "${d}" \
      && git -C "${d}" commit . -m "wip: $(date '+%F %T')" || true \
      && git -C "${d}" rebase 'development' \
      && nix flake lock --recreate-lock-file --commit-lock-file \
      && git -C "${d}" push origin HEAD -f)
