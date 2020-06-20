#!/usr/bin/env bash

mkdir -p ./clients

../../../misc/make-wireguard-client.sh 10 cole-phone
../../../misc/make-wireguard-client.sh 11 cole-laptop
../../../misc/make-wireguard-client.sh 20 bud-phone

