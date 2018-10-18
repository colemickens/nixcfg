#!/usr/bin/env bash
set -x
set -euo pipefail

##
## use github api to get latest commit for a repo
## use nix-prefetch-url to get the hash
## update files in place with `update-source-version`
##

export NIX_PATH=nixpkgs=/etc/nixpkgs-sway

cd /etc/nixpkgs-sway

function update() {
  attr="${1}"
  owner="${2}"
  repo="${3}"
  rev="$(curl "https://api.github.com/repos/${owner}/${repo}/commits" | jq -r ".[0].sha")"
  sha256="$(nix-prefetch-url --unpack "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz")"

  /etc/nixpkgs-sway/pkgs/common-updater/scripts/update-source-version \
    "${attr}" "${rev}" "${sha256}"

  return

  cat <<EOF
src = fetchFromGitHub {
  owner = "${owner}";
  repo = "${repo}";
  rev = "${rev}";
  sha256 = "${sha256}";
}
EOF
}

update "wlroots" "swaywm" "wlroots"
update "sway" "swaywm" "sway"
update "slurp" "emersion" "slurp"
update "grim" "emersion" "grim"

