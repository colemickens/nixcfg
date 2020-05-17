#!/usr/bin/env bash

set -euo pipefail
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export NIX_PATH="nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz"

# TODO: pre-emptively try to advance `cmpkgs`???

function update() {
  typ="${1}"
  pkg="${2}"

  metadata="${pkg}/metadata.nix"
  pkgname="$(basename "${pkg}")"

  branch="$(nix-instantiate "${metadata}" --eval --json -A branch | jq -r .)"
  rev="$(nix-instantiate "${metadata}" --eval --json -A rev | jq -r .)"
  date="$(nix-instantiate "${metadata}" --eval --json -A revdate | jq -r .)"
  sha256="$(nix-instantiate "${metadata}" --eval --json -A sha256 | jq -r .)"
  url="$(nix-instantiate "${metadata}" --eval --json -A url | jq -r .)"
  skip="$(nix-instantiate "${metadata}" --eval --json -A skip || echo "false" | jq -r .)"

  newdate="${date}"
  if [[ "${skip}" != "true" ]]; then
    # Determine RepoTyp (git/hg)
    if   nix-instantiate "${metadata}" --eval --json -A repo_git; then repotyp="git";
    elif nix-instantiate "${metadata}" --eval --json -A repo_hg; then repotyp="hg";
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

      # Update Sha256
      newsha256="$(nix-prefetch-url --unpack "${url}")"

      # TODO: do this with nix instead of sed?
      sed -i "s/${rev}/${newrev}/" "${metadata}"
      sed -i "s/${date}/${newdate}/" "${metadata}"
      sed -i "s/${sha256}/${newsha256}/" "${metadata}"
    fi
  fi
}

for p in imports/**/*; do
  update "nixpkgs" "${p}"
done

nix-build ./default.nix | cachix push colemickens

# TODO: (the following fails)
# nix-build-uncached ./default.nix | cachix push colemickens

echo "done with current nixpkgs"

echo "trying to upgrade nixpkgs"

# git clone it
# git check it out
# change the nixpkgs used for the machine
# build it anyway
