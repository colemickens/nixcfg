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

function commit() {
  git -C "${DIR}" commit -m "$1" "${DIR}"
}

function encrypt() {
  cd "${DIR}"
  mkdir -p encrypted; cd unencrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../encrypted/$f -e $f
  done
  commit "secrets: encrypted"
}

function import_keys() {
  cd "${DIR}/keys"
  for f in *.pub; do
    gpg --import "${f}"
  done
}

function regen_sops() {
  # TODO: this kinda sucks, lol
  cd "${DIR}/keys"
  cp "${DIR}/.sops.yaml" "${DIR}/.sops.yaml.old-$(date '+%s')" || true
  sops="${DIR}/.sops.yaml"
  cat >"${sops}" <<EOF
creation_rules:
  - path_regex: .*\$
    key_groups:
      - pgp: [ AUTO_KEYS ]
        age:
          - "age1qeav4nazvqudr0p55dq8thqlftplu4pu279vt6wddjzvdjfrgsyqr5qt68" # gha-age-key-pub
EOF
  AUTO_KEYS=""
  for f in *.fingerprint; do
    fp="$(cat "${f}" | tr -d '\n' | tr -d '\r')"
    AUTO_KEYS="$(printf '%s "%s",' "$AUTO_KEYS" "${fp}")"
  done
  sed -i "s/AUTO_KEYS/${AUTO_KEYS::-1}/g" "${sops}"
  bat "${DIR}/.sops.yaml"
}

function __new_host() {
  name="$1"
  addr="$2"
  rpath="$3"
  nix shell --no-write-lock-file github:Mic92/sops-nix#ssh-to-pgp --command "bash" -c "\
    ssh ${addr} \"sudo cat ${rpath}\" \
      | ssh-to-pgp -o keys/${name}.pub 2> \"keys/${name}.fingerprint\""

  "${0}" import_keys
  "${0}" regen_sops
  "${0}" encrypt
  
  commit "secrets: new host: ${name}"
}
function new_host() { __new_host "$1" "$2" "/etc/ssh/ssh_host_rsa_key"; }
function new_mnt_host() { __new_host "$1" "$2" "/mnt-$1/etc/ssh/ssh_host_rsa_key"; }


"${@}"
