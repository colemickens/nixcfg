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
}

function import_keys() {
  cd keys
  for f in *.pub; do
    gpg --import "${f}"
  done
}

"${@}"
