#!/usr/bin/env bash
# TODO: how to use a nixpkgs from the flake

# TODO: run this in extraDevShell (aria2c)
# TODO: adopt dev-shell project?

set -euo pipefail
set -x

# fetch upstream info
index="https://tails.boum.org/install/v2/Tails/amd64/stable/latest.json"
ver="$(curl --silent "${index}" | jq -r ".installations[0].version")"
fname="tails-amd64-${ver}.iso"

# temp workdir
OUTDIR="$(mktemp -d "/tmp/ktails.XXXXXX")";
trap "rm -rf ${OUTDIR}" EXIT

# outputs
CACHE="${KTAILS_CACHE:-"${HOME}/.cache/sliat"}"
img="${CACHE}/${fname}"
mkdir -p "${CACHE}"

aria2c --dir="${OUTDIR}" --seed-time=0 \
  "https://tails.boum.org/torrents/files/${fname}.torrent"
bash
mv "${OUTDIR}/tails-amd64-${ver}-img/${fname}" "${img}"
