#!/usr/bin/env bash

set -euo pipefail

host="${1}"
rm -f /tmp/result
sudo nixos-rebuild build --flake "${HOME}/code/nixcfg#$host" \
  && mv result /tmp/result \
  && readlink -f /tmp/result | cachix push colemickens \
  && ssh -v cole@$(tailscale ip --4 "${host}") "\
   nix-store -r $(readlink -f /tmp/result) \
     && sudo $(readlink -f /tmp/result)/bin/switch-to-configuration switch"
