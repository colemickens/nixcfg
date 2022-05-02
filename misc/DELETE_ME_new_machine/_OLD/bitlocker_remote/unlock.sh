#!/usr/bin/env bash
set -euo pipefail
set -x

GADGET="rpizero1"

ssh cole@$(tailscale ip --6 "${GADGET}") true

host="${1}"
pw="$(gopass show "misc/bitlocker_${host}" | grep recovery_key | cut -d' ' -f2)"

scp ./hidsetup.sh cole@$(tailscale ip --4 "${GADGET}"):/tmp/hidsetup.sh
ssh cole@$(tailscale ip --6 "${GADGET}") sudo /tmp/hidsetup.sh

ssh cole@$(tailscale ip --6 "${GADGET}") \
    "sudo kbsim -n \"${pw}\""
