#!/usr/bin/env bash

set -euo pipefail
set -x

name="${2}"
num="${1}"

srvpubkey="$(cat "wg-server.pub")"

mkdir -p "./clients/${name}"
cd ./clients/${name}
umask  077

if [[ ! -f "./client.key" ]]; then
  wg genkey | tr -d '\n' > "./client.key"
  cat "./client.key" | wg pubkey | tr -d '\n' > "./client.pub"
  cp ./client.pub ../../client-${num}-${name}.pub
fi

privkey="$(cat "./client.key")"

cat<<EOF >"./chimera-all.conf"
[Interface]
PrivateKey = ${privkey}
Address = 172.27.66.${num}/24
DNS = 192.168.1.1

[Peer]
PublicKey = ${srvpubkey}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = summit.mickens.us:51820
EOF

cat<<EOF >"./chimera-lan.conf"
[Interface]
PrivateKey = ${privkey}
Address = 172.27.66.${num}/24
DNS = 192.168.1.1

[Peer]
PublicKey = ${srvpubkey}
AllowedIPs = 192.168.1.0/24
Endpoint = summit.mickens.us:51820
EOF

cat "./chimera-lan.conf" | nix-shell -I nixpkgs=~/code/nixpkgs/cmpkgs -p qrencode \
  --command "qrencode -t png -o './chimera-lan.png'"

cat "./chimera-all.conf" | nix-shell -I nixpkgs=~/code/nixpkgs/cmpkgs -p qrencode \
  --command "qrencode -t png -o './chimera-all.png'"

echo "done" &>/dev/stderr
