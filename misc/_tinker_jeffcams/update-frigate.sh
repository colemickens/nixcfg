#!/usr/bin/env bash

set -euo pipefail
set -x

rm /tmp/frigate.yml
nix build -f ./frigate.yml.nix --out-link /tmp/frigate.yml
scp /tmp/frigate.yml cole@$(tailscale ip --6 homeassistant):config/frigate.yml
