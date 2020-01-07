#!/usr/bin/env bash

set -euo pipefail
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export NIX_PATH="nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz"

# keep track of what we build for the README
pkgentries=(); nixpkgentries=();
build_attr="${1:-"xeep-sway"}"

function update() {
  typ="${1}"
  pkg="${2}"

  metadata="${pkg}/metadata.nix"
  pkgname="$(basename "${pkg}")"

  branch="$(nix eval --raw -f "${metadata}" branch)"
  rev="$(nix eval --raw -f "${metadata}" rev)"
  date="$(nix eval --raw -f "${metadata}" revdate)"
  sha256="$(nix eval --raw -f "${metadata}" sha256)"
  url="$(nix eval --raw -f "${metadata}" url)"
  skip="$(nix eval -f "${metadata}" skip || true)"

  newdate="${date}"
  if [[ "${skip}" != "true" ]]; then
    # Determine RepoTyp (git/hg)
    if   nix eval --raw -f "${metadata}" repo_git; then repotyp="git";
    elif nix eval --raw -f "${metadata}" repo_hg;  then repotyp="hg";
    else echo "unknown repo_typ" && exit -1;
    fi

    # Update Rev
    if [[ "${repotyp}" == "git" ]]; then
      repo="$(nix eval --raw -f "${metadata}" repo_git)"
      newrev="$(git ls-remote "${repo}" "${branch}" | awk '{ print $1}')"
    elif [[ "${repotyp}" == "hg" ]]; then
      repo="$(nix eval --raw -f "${metadata}" repo_hg)"
      newrev="$(hg identify "${repo}" -r "${branch}")"
    fi
    
    if [[ "${rev}" != "${newrev}" ]]; then
      # Update RevDate
      d="$(mktemp -d)"
      if [[ "${repotyp}" == "git" ]]; then
        git clone -b "${branch}" --single-branch --depth=1 "${repo}" "${d}"
        newdate="$(cd "${d}"; git log --format=%ci --max-count=1)"
      elif [[ "${repotyp}" == "hg" ]]; then
        hg clone "${repo}#${branch}" "${d}"
        newdate="$(cd "${d}"; hg log -r1 --template '{date|isodate}')"
      fi
      rm -rf "${d}"

      newsha256="$(nix-prefetch-url --unpack "${url}")"

      # TODO: do this with nix instead of sed?
      sed -i "s/${rev}/${newrev}/" "${metadata}"
      sed -i "s/${date}/${newdate}/" "${metadata}"
      sed -i "s/${sha256}/${newsha256}/" "${metadata}"
    fi
  fi
}

for p in imports/*; do
  update "nixpkgs" "${p}"
done

sudo bash -c "ulimit -s 100000; nix-build default.nix --no-out-link --keep-going --attr ${build_attr}"
