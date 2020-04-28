#!/usr/bin/env bash
set -euo pipefail
set -x

sudo true

machinename="$(hostname)"
remote="self"

if [[ "${1:-""}" != "" ]]; then
  machinename="${1}"
  remote="${2}"
  port="${3}"
fi

toplevel="$(./nixbuild.sh "./machines/${machinename}")"

if [[ "${remote}" == "self" ]]; then
  sudo bash -c "\
    nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch"
else
  NIX_SSHOPTS="-p ${port}" nix-copy-closure --to "ssh://${remote}" "${toplevel}"
  ssh "${remote}" -p "${port}" "\
    sudo bash -c \" nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch\""
fi

