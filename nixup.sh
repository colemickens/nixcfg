#! /usr/bin/env nix-shell
#! nix-shell -I nixpkgs=/home/cole/code/nixpkgs/cmpkgs -i bash -p nixFlakes

set -euo pipefail
set -x

function nix() {
  command nix --experimental-features 'nix-command flakes' "${@}"
}

machinename="$(hostname)"
remote="self"

mode="build"
if [[ "${1:-""}" == "x" ]]; then
  mode="update"
  shift
elif [[ "${1:-""}" == "flake" ]]; then
  mode="flake"
  shift
fi

if [[ "${1:-""}" != "" ]]; then
  machinename="${1}"
  remote="${2}"
  port="${3}"
fi

if [[ "${mode}" == "update" ]]; then
  (cd ~/code/nixpkgs/master;
    git remote update;
    git reset --hard nixpkgs/master && git push origin HEAD -f)
  
  (cd ~/code/nixpkgs/cmpkgs;
    git rebase nixpkgs/nixos-unstable-small && git push origin HEAD -f) || true

  (cd ~/code/nixpkgs/rpi;
    git rebase nixpkgs/nixos-unstable && git push origin HEAD -f) || true

  (cd ~/code/extras/home-manager;
    git remote update;
    git rebase rycee/master || git rebase --abort)

  (cd ~/code/overlays/nixpkgs-wayland;
    git remote update;
    git rebase origin/master || git rebase --abort)

  (cd ~/code/nixcfg; ./update-imports.sh)
elif [[ "${mode}" == "flake" ]]; then
  (
    cd ~/code/nixcfg
    tl='.#nixosConfigurations.xeep.config.system.build.toplevel'

    nix flake update --no-registries
    nix build "${tl}" --show-trace

    if [[ ! -z "${SWITCH:-""}" ]]; then
      nix shell -vv "${tl}" -c switch-to-configuration switch
    fi
  )
  exit
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

