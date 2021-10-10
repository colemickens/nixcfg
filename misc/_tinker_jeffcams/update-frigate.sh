#!/usr/bin/env bash

set -euo pipefail
set -x

rm -f /tmp/frigate.json
nix build -f ./frigate.nix --out-link /tmp/frigate.json
ssh cole@$(tailscale ip --6 homeassistant) sudo rm -f /tmp/frigate.yml /config/frigate.yml
scp /tmp/frigate.json cole@"[$(tailscale ip --6 homeassistant)]":/tmp/frigate.yml
ssh cole@$(tailscale ip --6 homeassistant) sudo mv /tmp/frigate.yml /config/frigate.yml
ssh cole@$(tailscale ip --6 homeassistant) 'sudo /usr/local/bin/docker kill $(sudo /usr/local/bin/docker ps | grep frigate | head -1 | cut -d\  -f1)'
