#! /usr/bin/env bash
set -euo pipefail

srcdirs=(
  "${HOME}/code/nixpkgs/master"
  "${HOME}/code/nixpkgs/cmpkgs"
  "${HOME}/code/nixpkgs/cmpkgs-cross-riscv64"
  "${HOME}/code/nixpkgs/cmpkgs-cross-armv6l"
  "${HOME}/code/home-manager/master"
  "${HOME}/code/home-manager/cmhm"
  "${HOME}/code/tow-boot/development"
  "${HOME}/code/tow-boot/rpi"
  "${HOME}/code/tow-boot/radxa-zero"
  "${HOME}/code/tow-boot/visionfive"
  "${HOME}/code/nixpkgs-wayland/master"
  "${HOME}/code/flake-firefox-nightly"
  "${HOME}/code/mobile-nixos/master"
  "${HOME}/code/mobile-nixos/blueline-mainline-only--2022-08"
  "${HOME}/code/mobile-nixos/openstick"
  "${HOME}/code/linux/master"
)

for s in "${srcdirs[@]}"; do
  printf "==:: inputup: ${s}\n" >&2
  test -d "${s}" || return;
  git -C "${s}" rebase --abort &>/dev/null || true
  git -C "${s}" pull --rebase;  git -C "${s}" push origin HEAD -f;
  printf "\n" >&2
done;
