#!/usr/bin/env bash

# TODO: git-crypt */wireguard/*.key

#./make-wireguard-client.sh client-cole-pixel3
#./make-wireguard-client.sh client-buddie-pixel3
#./make-wireguard-client.sh client-jeff-pixel3

set -x

name="${1}"
num="${2}"

umask  077

wg genkey | tr -d '\n' > "${name}.key"
cat "${name}.key" | wg pubkey | tr -d '\n' > "${name}.pub"

privkey="$(cat "${name}.key")"
srvpubkey="$(cat "server.pub")"

cat<<EOF >"${name}.conf"
[Interface]
PrivateKey = ${privkey}
Address = 192.168.2.${num}/24
DNS = 192.168.1.1

[Peer]
PublicKey = ${srvpubkey}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = cleothecat.duckdns.org:51820
EOF

echo "done" &>/dev/stderr
