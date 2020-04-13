#!/usr/bin/env bash
set -euo pipefail
set -x

machinename="$(hostname)"
remote="self"

if [[ "${1:-""}" != "" ]]; then
  machinename="${1}"
  remote="${2}"
  port="${3}"
fi

toplevel="$(./nixbuild.sh "./machines/${machinename}")"

if [[ "${remote}" == "self" ]]; then
  sudo nix-env --set --profile '/nix/var/nix/profiles/system' "${toplevel}"
  sudo "${toplevel}/bin/switch-to-configuration" switch
else
  NIX_SSHOPTS="-p ${port}" nix-copy-closure --to "ssh://${remote}" "${toplevel}"
  ssh "${remote}" -p "${port}" "sudo nix-env --set --profile '/nix/var/nix/profiles/system' '${toplevel}'"
  ssh "${remote}" -p "${port}" "sudo '${toplevel}/bin/switch-to-configuration' switch"
fi

