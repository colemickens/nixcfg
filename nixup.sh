#!/usr/bin/env bash

set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

target="$(hostname)_sway__local"
#target="$(hostname)_gnomeshell__local"
toplevel=$(./nixbuild.sh default.nix -A "${target}.config.system.build.toplevel")

sudo nix-env --set \
  --profile "/nix/var/nix/profiles/system" \
  "${toplevel}"

sudo "${toplevel}/bin/switch-to-configuration" switch
