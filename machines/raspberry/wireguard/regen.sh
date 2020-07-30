#!/usr/bin/env bash

if [[ ! -f ./server.key ]]; then
  wg genkey >./server.key
  wg pubkey <./server.key >./server.pub
fi

sops --encrypt ./server.key > ./server.key.sops
sops --encrypt ./server.pub > ./server.pub.sops

mkdir -p ./clients

./make-wireguard-client.sh 10 cole-phone
./make-wireguard-client.sh 11 cole-laptop
./make-wireguard-client.sh 20 bud-phone

