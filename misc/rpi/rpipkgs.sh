#!/usr/bin/env bash
set -x
set -euo pipefail

    (d="${HOME}/code/nixpkgs/cmpkgs"; cd "${d}" \
      && git -C "${d}" remote update \
      && git -C "${d}" rebase 'nixos/nixos-unstable')
    (d="${HOME}/code/nixpkgs/rpi"; cd "${d}" \
      && git -C "${d}" remote update \
      && git -C "${d}" rebase 'nixos/nixos-unstable')
    (d="${HOME}/code/nixcfg/misc/rpi"; cd "${d}" \
      && ./update-rpi-packages.sh)
    (d="${HOME}/code/nixpkgs/rpipkgs"; cd "${d}" \
      && git -C "${d}" reset --hard rpi-updates-auto \
      && git -C "${d}" rebase cmpkgs \
      && git -C "${d}" push origin HEAD -f)
    (d="${HOME}/code/tow-boot/development"; cd "${d}" \
      && git -C "${d}" remote update \
      && git -C "${d}" reset --hard 'tow-boot/development')
    (d="${HOME}/code/tow-boot/rpi"; cd "${d}" \
      && git -C "${d}" commit . -m "wip: $(date '+%F %T')" || true \
      && git -C "${d}" rebase 'development' \
      && nix flake lock --recreate-lock-file --commit-lock-file \
      && git -C "${d}" push origin HEAD -f)
    # (d="${HOME}/code/tow-boot/pinephone-emmc-vccq-mod"; cd "${d}" \
    #   && git -C "${d}" commit . -m "wip: $(date '+%F %T')" || true \
    #   && git -C "${d}" rebase 'rpi' \
    #   && nix flake lock --recreate-lock-file --commit-lock-file \
    #   && git -C "${d}" push origin HEAD -f)
    (d="${HOME}/code/nixcfg"; cd "${d}" \
      && nix flake lock --update-input rpipkgs --commit-lock-file \
      && nix flake lock --update-input tow-boot --commit-lock-file)
