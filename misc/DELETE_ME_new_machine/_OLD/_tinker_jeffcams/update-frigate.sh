#!/usr/bin/env bash

set -euo pipefail
set -x

pushd ../..
./nixup jeffhyper || true
popd

sudo rm -f /tmp/frigate.yml
scp cole@"[$(tailscale ip --6 jeffhyper)]":/etc/fyi/frigate.yml /tmp/frigate.yml
ssh cole@$(tailscale ip --6 homeassistant) sudo rm -f /tmp/frigate.yml /config/frigate.yml
scp /tmp/frigate.yml cole@"[$(tailscale ip --6 homeassistant)]":/tmp/frigate.yml
ssh cole@$(tailscale ip --6 homeassistant) sudo mv /tmp/frigate.yml /config/frigate.yml
ssh cole@$(tailscale ip --6 homeassistant) 'sudo /usr/local/bin/docker kill $(sudo /usr/local/bin/docker ps | grep frigate | head -1 | cut -d\  -f1)'
