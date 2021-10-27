#! /usr/bin/env bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/stderr 2>&1 && pwd )"
cd "${DIR}"

set -x

ssh "colemickens@aarch64.nixos.community" \
  "nix-env -f /run/current-system/nixpkgs -iA \
    git zellij nixUnstable htop ncdu file nix-top ncdu neovim cachix"

ssh "colemickens@aarch64.nixos.community" \
  "rm -rf ~/.config/cachix; mkdir -p ~/.config/cachix; mkdir -p ~/.config/nix; mkdir -p ~/code/"
scp "${HOME}/.config/cachix/cachix.dhall" "colemickens@aarch64.nixos.community:~/.config/cachix/cachix.dhall"

# TODO: keep in sync: commbox.sh/install-nix.sh
cat<<EOF >/tmp/nix.conf
experimental-features = nix-command flakes ca-references
extra-substituters = https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org
extra-trusted-public-keys = colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso=
trusted-users = root @sudo
cores = 0
max-jobs = auto
EOF

scp /tmp/nix.conf \
  "colemickens@aarch64.nixos.community:~/.config/nix/nix.conf"

ssh "colemickens@aarch64.nixos.community" \
  "[[ ! -d ~/code/nixcfg ]] && git clone https://github.com/colemickens/nixcfg ~/code/nixcfg"