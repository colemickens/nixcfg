#!/usr/bin/env bash
set -x
set -euo pipefail

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

ssh -T -L 18384:localhost:8384 cole@$(tailscale ip --4 slynux) &
ssh -T -L 28384:localhost:8384 cole@$(tailscale ip --4 raisin) &
ssh -T -L 38384:localhost:8384 cole@$(tailscale ip --4 xeep)
