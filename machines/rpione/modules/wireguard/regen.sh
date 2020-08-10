#!/usr/bin/env bash
set -euo pipefail
set -x

keypath="../../../secrets/unencrypted/wg-server.key"
clientbundle="../../../secrets/unencrypted/wg-clients.tar.gz"
if [[ ! -f "${keypath}" ]]; then
  wg genkey >"${keypath}"
  wg pubkey <"${keypath}" >./wg-server.pub
fi

mkdir -p ./clients

./make-wireguard-client.sh 10 cole-phone
./make-wireguard-client.sh 11 cole-laptop
./make-wireguard-client.sh 20 bud-phone

tar czf "${clientbundle}" clients
rm -rf clients

cd ../../../secrets; ./util.sh e
