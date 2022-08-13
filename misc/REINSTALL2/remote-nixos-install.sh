#!/usr/bin/env bash

HOST="${1}"
TARGET="${2}"
CACHIX="${CACHIX:-"colemickens"}"

# build locally, push to cachix (that is already used by the installer image)
nix build ".#toplevels.${HOST}" --out-link /tmp/resultx
readlink -f /tmp/resultx | cachix push "${CACHIX}"

SYSTEM="$(readlink -f /tmp/resultx)"

# copy installer script over (easier than doing it all over ssh, fucking yuck)
scp ./nixos-install.sh "${TARGET}:/home/cole/nixos-install.sh"

# run the installer with our pre-built system

# TODO: DISK SETUP?????

ssh "${TARGET}" "/home/cole/nixos-install.sh" "${SYSTEM}"
