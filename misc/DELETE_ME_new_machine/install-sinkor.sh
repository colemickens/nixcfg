#!/usr/bin/env bash

set -euo pipefail
stash
_remote "${a64com}" "toplevels.sinkor" "cachix"
out="$(nix eval --raw ".#toplevels.sinkor.outPath")"
target="nixos@192.168.133.202"
SSH_AUTH_SOCK=/run/user/1000/sshagent  ssh-copy-id "${target}"
scp "hosts/_new/disk.sh" ${target}:/tmp/disk.sh
ssh "${target}" /tmp/disk.sh install $out
