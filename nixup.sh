#!/usr/bin/env bash
set -euo pipefail
set -x

if [[ "${1:-""}" == "" ]]; then
  machinename="$(hostname)"
  remote="self"
else
  machinename="${1}"
  remote="${2}"
  port="${3}"
fi


toplevel="$(nix-build \
  --builders-use-substitutes \
  --builders 'ssh://colemickens@aarch64.nixos.community aarch64-linux /home/cole/.ssh/id_ed25519; ssh://cole@azdev.westus2.cloudapp.azure.com x86_64-linux /home/cole/.ssh/id_ed25519' \
  -A "${machinename}" default.nix)"

if [[ "${remote}" == "self" ]]; then
  sudo nix-env --set --profile '/nix/var/nix/profiles/system' "${toplevel}"
  sudo "${toplevel}/bin/switch-to-configuration" switch
else
  NIX_SSHOPTS="-p ${port}" nix copy --to "ssh://${remote}" "${toplevel}"
  ssh "${remote}" -p "${port}" "sudo nix-env --set --profile '/nix/var/nix/profiles/system' '${toplevel}'"
  ssh "${remote}" -p "${port}" "sudo '${toplevel}/bin/switch-to-configuration' switch"
fi

