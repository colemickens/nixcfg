#!/usr/bin/env bash

set -euo pipefail
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# keep track of what we build for the README
defaultcommitmsg="auto-updates:"
pkgentries=(); nixpkgentries=(); commitmsg="${defaultcommitmsg}";

up=0 # updated_performed # up=$(( $up + 1 ))
nixpkgs="https://api.github.com/repos/$(jq -r '.nodes.nixpkgs.locked.owner' ../flake.lock)/$(jq -r '.nodes.nixpkgs.locked.repo' ../flake.lock)/tarball/$(jq -r '.nodes.nixpkgs.locked.rev' ../flake.lock)"
export NIX_PATH="nixpkgs=${nixpkgs}"

function update() {
  #set +x
  set -euo pipefail
  typ="${1}"
  pkg="${2}"

  echo "============================================================================"
  echo "${pkg}: checking"

  if [[ ! -f "${pkg}/metadata.nix" ]]; then
    return
  fi

  metadata="${pkg}/metadata.nix"
  pkgname="$(basename "${pkg}")"

  # TODO: nix2json, update in parallel
  # TODO: aka, not in bash

  branch="$(nix-instantiate "${metadata}" --eval --json -A branch 2>/dev/null | jq -r .)"
  rev="$(nix-instantiate "${metadata}" --eval --json -A rev  2>/dev/null | jq -r .)"
  sha256="$(nix-instantiate "${metadata}" --eval --json -A sha256  2>/dev/null | jq -r .)"
  upattr="$(nix-instantiate "${metadata}" --eval --json -A upattr  2>/dev/null | jq -r . || echo "${pkgname}")"
  url="$(nix-instantiate "${metadata}" --eval --json -A url  2>/dev/null | jq -r . || echo "missing_url")"
  cargoSha256="$(nix-instantiate "${metadata}" --eval --json -A cargoSha256  2>/dev/null | jq -r . || echo "missing_cargoSha256")"
  vendorSha256="$(nix-instantiate "${metadata}" --eval --json -A vendorSha256  2>/dev/null | jq -r . || echo "missing_vendorSha256")"
  skip="$(nix-instantiate "${metadata}" --eval --json -A skip  2>/dev/null | jq -r . || echo "false")"

  if [[ "${skip}" != "true" ]]; then
    # Determine RepoTyp (git/hg)
    if   nix-instantiate "${metadata}" --eval --json -A repo_git &>/dev/null; then repotyp="git";
    elif nix-instantiate "${metadata}" --eval --json -A repo_hg &>/dev/null; then repotyp="hg";
    else echo "unknown repo_typ" && exit -1;
    fi

    # Update Rev
    if [[ "${repotyp}" == "git" ]]; then
      repo="$(nix-instantiate "${metadata}" --eval --json -A repo_git | jq -r .)"
      newrev="$(git ls-remote "${repo}" "${branch}" | awk '{ print $1}')"
    elif [[ "${repotyp}" == "hg" ]]; then
      repo="$(nix-instantiate "${metadata}" --eval --json -A repo_hg | jq -r .)"
      newrev="$(hg identify "${repo}" -r "${branch}")"
    fi

    if [[ "${rev}" != "${newrev}" ]]; then
      up=$(( $up + 1 ))
      commitmsg="${commitmsg} ${pkgname},"

      echo "${pkg}: ${rev} => ${newrev}"

      set -x

      # Update Sha256
      if [[ "${typ}" == "pkgs" ]]; then
        newsha256="$(nix-prefetch --output raw \
            -E "(import ./build.nix).${upattr}" \
            --rev "${newrev}")"
      elif [[ "${typ}" == "nixpkgs" ]]; then
        newsha256="$(nix-prefetch-url --unpack "${url}" 2>/dev/null)"
      fi

      # TODO: do this with nix instead of sed?
      sed -i "s/${rev}/${newrev}/" "${metadata}"
      sed -i "s|${sha256}|${newsha256}|" "${metadata}"

      # CargoSha256 has to happen AFTER the other rev/sha256 bump
      if [[ "${cargoSha256}" != "missing_cargoSha256" ]]; then
        newcargoSha256="$(nix-prefetch \
            "{ sha256 }: let p=(import ./build.nix).${upattr}; in p.cargoDeps.overrideAttrs (_: { cargoSha256 = sha256; })")"
        sed -i "s|${cargoSha256}|${newcargoSha256}|" "${metadata}"
      fi

      # VendorSha256 has to happen AFTER the other rev/sha256 bump
      if [[ "${vendorSha256}" != "missing_vendorSha256" ]]; then
        newvendorSha256="$(nix-prefetch \
            "{ sha256 }: let p=(import ./build.nix).${upattr}; in p.go-modules.overrideAttrs (_: { vendorSha256 = sha256; })")"
        sed -i "s|${vendorSha256}|${newvendorSha256}|" "${metadata}"
      fi

      set +x
    fi
  fi
}

if [[ "${1:-""}" == "internal" ]]; then
  update $2
fi

for p in ./*/; do
  update "pkgs" "${p}"
done

echo "all done."

