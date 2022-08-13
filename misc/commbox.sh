#! /usr/bin/env bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/stderr 2>&1 && pwd )"
cd "${DIR}"

set -x
remote="colemickens@aarch64.nixos.community"

pexit=0; set +e
ssh "${remote}" \
  "bash -c 'set -xe; \
    test -d /home/colemickens/.config/cachix && exit 199; \
    nix-env -f /run/current-system/nixpkgs -iA git zellij nixUnstable bottom helix cachix file ripgrep exa; \
    rm -rf ~/.config/cachix; mkdir -p ~/.config/cachix; mkdir -p ~/.config/nix; exit 198 \
  '"
pexit=$?; set -e
if [[ $pexit != 199 || $pexit != 198 ]]; then test $pexit; fi

echo "PEXIT=${pexit}"
if [[ $pexit == 199 ]]; then
  echo "already provisioned"
  exit 0
elif [[ $pexit != 198 ]]; then
  echo "unknown error!"
  exit -1
fi

echo "need to finish provisioning"
scp "${HOME}/.config/cachix/cachix.dhall" "${remote}:~/.config/cachix/cachix.dhall"

# nix.conf
t="$(mktemp)"
trap "rm ${t}" EXIT;
cat >"${t}" <<EOF
experimental-features = nix-command flakes
substituters = https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org
trusted-public-keys = colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso=
trusted-users = root @sudo colemickens
cores = 0
max-jobs = auto
EOF

scp "${t}" "${remote}:~/.config/nix/nix.conf"

#
# done
