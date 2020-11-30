#!/usr/bin/env bash
set -euo pipefail
set -x


function d() {
  mkdir -p encrypted; cd encrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../unencrypted/$f -d $f
  done
}

function e() {
  mkdir -p unencrypted; cd unencrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../encrypted/$f -e $f
  done
}

"${@}"
