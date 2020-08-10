#!/usr/bin/env bash
set -euo pipefail
set -x

function ssh-to-pgp() {
  nix --experimental-features 'nix-command flakes' \
    run 'github:Mic92/sops-nix#ssh-to-pgp' -- "${@}"
  #command ~/code/sops-nix/ssh-to-pgp "${@}"
}

function d() {
  cd encrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../unencrypted/$f -d $f
  done
}

function e() {
  cd unencrypted
  for f in *; do
    sops \
      --input-type binary --output-type binary \
      --verbose --output ../encrypted/$f -e $f
  done
}

function keys() {
  mkdir -p ./keys
  
  

  set +x # fucking bash (otherwise it shits out a set-x echo line into the fp file)
  host="rpione"
  ssh "cole@192.168.1.2" "sudo cat /etc/ssh/ssh_host_rsa_key" \
    | ssh-to-pgp -o "./keys/${host}.pub" 2> "./keys/${host}.fingerprint"
  
  set +x # fucking bash
  host="xeep"
  ssh "cole@${host}" "sudo cat /etc/ssh/ssh_host_rsa_key" \
    | ssh-to-pgp -o "./keys/${host}.pub" 2> "./keys/${host}.fingerprint"
  
  set -x
  kid="0x62556A61E301DC21" # colemickens
  gpg --fingerprint --fingerprint "${kid}" | grep -A1 "${kid}"  \
    | tail -1 | cut -d' ' -f10- | tr -d ' ' > ./keys/colemickens.fingerprint
  gpg --armor --export "${kid}" >./keys/colemickens.pub

  kid="0xD7FA118E53E6D398" # srht-builder
  gpg --fingerprint --fingerprint "${kid}" | grep -A1 "${kid}"  \
    | tail -1 | cut -d' ' -f10- | tr -d ' ' > ./keys/srht-builder.fingerprint
  gpg --armor --export "${kid}" >./keys/srht-builder.pub

  echo "all done"
}

# hopefully replace all of this with age+piv soon
function newkey() {
  host="${1}"; shift
  # generate ssh
  # ssh-to-pgp
  # do our usual conversion out
  # add it to 'keys' function here
  d="$(mktemp -d)"; # trap "rm -rf $d" EXIT

  ssh-keygen -q -t rsa -N '' -f "${d}/id_rsa" <<<y 2>&1 >/dev/null
  ssh-to-pgp -private-key -i "${d}/id_rsa" > ./unencrypted/${host}.asc
  cat "${d}/id_rsa" | ssh-to-pgp -o "keys/${host}.pub" 2>"./keys/${host}.fingerprint"
  
  # copy to yubikey?
  echo "now maybe copy ./unencrypted/${host}.asc to yubikey"

  # is there a tool that automates that...?
}

cmd="${1}"; shift
${cmd} "${@}"

