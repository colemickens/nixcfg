#!/usr/bin/env bash

# ./make-wireguard-client.sh 2 cole1
# ./make-wireguard-client.sh 3 bud1
# ./make-wireguard-client.sh 4 cole2

set -x

name="${2}"
num="${1}"

srvpubkey="$(cat "server.pub")"

mkdir -p "./clients/${name}"
cd ./clients/${name}
umask  077

if [[ ! -f "./client.key" ]]; then
  wg genkey | tr -d '\n' > "./client.key"
  cat "./client.key" | wg pubkey | tr -d '\n' > "./client.pub"
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

sops --encrypt ./client.key > ./client.key.sops
sops --encrypt ./client.pub > ./client.pub.sops
sops --encrypt ./chimera-lan.conf > ./chimera-lan.conf.sops
sops --encrypt ./chimera-all.conf > ./chimera-all.conf.sops
sops --encrypt ./chimera-lan.png > ./chimera-lan.png.sops
sops --encrypt ./chimera-all.png > ./chimera-all.png.sops

echo "done" &>/dev/stderr
