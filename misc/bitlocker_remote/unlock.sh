#!/usr/bin/env bash
set -euo pipefail

echo "don't forget to run 'hid.sh' on device"

host="${1}"
pw="$(gopass show "misc/bitlocker_${host}" | grep recovery_key | cut -d' ' -f2)"

ssh cole@$(tailscale ip --6 rpizero1) \
    "sudo kbsim -n \"${pw}\""
