#!/usr/bin/env bash
set -euo pipefail
set -x

sudo true

machinename="$(hostname)"
remote="self"

mode="build"
if [[ "${1:-""}" == "x" ]]; then
  mode="update"
  shift
fi

if [[ "${1:-""}" != "" ]]; then
  machinename="${1}"
  remote="${2}"
  port="${3}"
fi

if [[ "${mode}" == "update" ]]; then
  (cd ~/code/nixpkgs/cmpkgs;
    git remote update;
    git rebase nixpkgs/nixos-unstable-small && git push origin HEAD -f) || true

  (cd ~/code/overlays/nixpkgs-wayland;
    git remote update;
    git pull --rebase) || true

  (cd ~/code/nixcfg; ./update-imports.sh)
fi

cd ~/code/nixcfg

if [[ "${remote}" == "self" ]]; then
  toplevel="$(./nixbuild.sh "./machines/${machinename}")"
  sudo bash -c "\
    nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch"

elif true; then
  toplevel="$(./nixbuild.sh "./machines/${machinename}")"
  NIX_SSHOPTS="-p ${port}" nix-copy-closure --to "ssh://${remote}" "${toplevel}"
  ssh "${remote}" -p "${port}" "\
    sudo bash -c \" nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch\""

else
  drv="$(nix-instantiate "./machines/${machinename}")"

  #cachixremote="colemickens"
  #cachixkey="$(gopass show websites/cachix.org/gh | grep "cachix_key_${cachixremote}" | cut -d' ' -f2)"

  nix-copy-closure --to "ssh://${remote}" "${drv}"

  ssh "${remote}" \
    "nix-build -j1 ${drv}"

  ssh "${remote}" -p "${port}" "\
    sudo bash -c \" nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch\""
fi

