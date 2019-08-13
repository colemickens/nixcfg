#!/usr/bin/env bash
set -euo pipefail
set -x

unset NIX_PATH

cachixremote="colemickens"

function update() {
  attr="${1}"
  owner="${2}"
  repo="${3}"
  ref="${4}"

  rev=""
  url="https://api.github.com/repos/${owner}/${repo}/commits?sha=${ref}"
  rev="$(git ls-remote "https://github.com/${owner}/${repo}" "${ref}" | cut -d '	' -f1)"
  [[ -f "./${attr}/metadata.nix" ]] && oldrev="$(nix eval -f "./${attr}/metadata.nix" rev --raw)"
  if [[ "${oldrev:-}" != "${rev}" ]]; then
    revShort="$(git rev-parse --short "${rev}")"
    revdata="$(curl -L --fail "https://api.github.com/repos/${owner}/${repo}/commits/${rev}")"
    revdate="$(echo "${revdata}" | jq -r ".commit.committer.date")"
    sha256="$(nix-prefetch-url --unpack "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz" 2>/dev/null)"
    printf '{\n  owner = "%s";\n  repo = "%s";\n  rev = "%s";\n  revShort = "%s";\n  sha256 = "%s";\n  revdate = "%s";\n}\n' \
      "${owner}" "${repo}" "${rev}" "${revShort}" "${sha256}" "${revdate}" > "./${attr}/metadata.nix"
  fi
}
update "imports/nixpkgs/nixos-unstable"    "nixos"       "nixpkgs-channels" "nixos-unstable"
update "imports/nixpkgs/cmpkgs"            "colemickens" "nixpkgs"          "cmpkgs"
update "imports/misc/nixos-hardware"   "nixos"       "nixos-hardware"   "master"
update "imports/overlays/nixpkgs-mozilla"  "mozilla"     "nixpkgs-mozilla"  "master"
update "imports/overlays/nixpkgs-wayland"  "colemickens" "nixpkgs-wayland"  "master"

update "overlay/pkgs/gopass"  "gopasspw" "gopass" "master"
update "overlay/pkgs/mesa"    "mesa3d" "mesa" "master"
#update "overlay/pkgs/libdrm"  "mesa3d" "libdrm" "master"

./nixbuild.sh default.nix -A "xeep_sway__local.config.system.build.toplevel" \
  | cachix push "${cachixremote}"
./nixbuild.sh default.nix -A "xeep_gnome__local.config.system.build.toplevel" \
  | cachix push "${cachixremote}"
./nixbuild.sh default.nix -A "xeep_plasma__local.config.system.build.toplevel" \
  | cachix push "${cachixremote}"

