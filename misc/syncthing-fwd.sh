#!/usr/bin/env bash

set -x
set -euo pipefail

ssh -L "$1:localhost:8384" "cole@$(tailscale ip --4 "$2")"
