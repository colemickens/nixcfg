#!/usr/bin/env bash
set -euo pipefail
set -x


function d() {
  mkdir -p unencrypted; cd encrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../unencrypted/$f -d $f
  done
}

function e() {
  mkdir -p encrypted; cd unencrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../encrypted/$f -e $f
  done
  (cd ..; git add .)
}

import_host() {
  name="$1"
  addr="$2"
  nix shell github:Mic92/sops-nix#ssh-to-pgp --command "bash" \
    -c "ssh cole@${addr} \"sudo cat /etc/ssh/ssh_host_rsa_key\" | ssh-to-pgp -o keys/${name}.pub 2> \"keys/${name}.fingerprint\""
}

function import_keys() {
  cd keys
  for f in *.pub; do
    gpg --import "${f}"
  done
}

"${@}"
