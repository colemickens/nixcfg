#!/usr/bin/env bash
set -euo pipefail
set -x

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function decrypt() {
  cd "${DIR}"
  mkdir -p unencrypted; cd encrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../unencrypted/$f -d $f
  done
}

function encrypt() {
  cd "${DIR}"
  mkdir -p encrypted; cd unencrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../encrypted/$f -e $f
  done
}

function regen_sops() {
  # TODO: this kinda sucks, lol
  cd "${DIR}/keys"
  sops="${DIR}/.sops.yaml"
  echo -e ${sops}
  cat >"${sops}" <<EOF
# v4
creation_rules:
  - path_regex: .*\$
    key_groups:
      - age: [ AUTO_KEYS ]
EOF
  AUTO_KEYS=""
  for f in *.age.pub; do
    fp="$(cat "${f}" | tr -d '\n' | tr -d '\r')"
    AUTO_KEYS="$(printf '%s %s, ' "$AUTO_KEYS" "${fp}")"
    
  done
  sed -i "s/AUTO_KEYS/${AUTO_KEYS::-1}/g" "${sops}"
}

function __new_host() {
  name="$1"
  addr="$2"
  prefix="$3"
  mkdir -p keys
  ssh "${addr}" cat "${prefix}etc/ssh/ssh_host_ed25519_key.pub" > "keys/${name}.pub"
  nix shell --no-write-lock-file github:Mic92/ssh-to-age#ssh-to-age --command \
    ssh-to-age -i "keys/${name}.pub" -o "keys/${name}.age.pub"

  "${0}" regen_sops
}

function new_host() { __new_host "$1" "$2" "/"; }
function new_mnt_host() { __new_host "$1" "$2" "/mnt-$1/"; }


"${@}"
