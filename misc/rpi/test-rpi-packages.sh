#!/bin/sh
set -euo pipefail
set -x

export NIXPKGS_WORKTREE="/home/cole/code/nixpkgs/rpi-updates-auto"
export TOWBOOT="/home/cole/code/tow-boot"

export TESTHOST="${1:-}"; shift || true

#
# DEPLOY+ACTIVATE "${TESTHOST}" TOPLEVEL
if [[ "${TESTHOST}" != "" ]]; then
  ../../nixup "${TESTHOST}" \
    --override-input 'tow-boot' "${TOWBOOT}" \
    --override-input 'nixpkgs' "${NIXPKGS_WORKTREE}"

  ssh cole@"$(tailscale ip --6 "${TESTHOST}")" "sudo tow-boot-rpi-update"
  ssh cole@"$(tailscale ip --6 "${TESTHOST}")" "sudo reboot" || true

  stop=0
  while [[ "${stop}" == 0 ]]; do
    ssh \
      -o ConnectTimeout=5 \
      cole@"$(tailscale ip --6 "${TESTHOST}")" \
        "uname -a" && stop=1 || true
    sleep 5
  done

  exit 0
fi

"${0}" rpifour1
"${0}" rpizerotwo1

# #
# # DEPLOY+ACTIVATE RPIZEROTWO1 TOPLEVEL
# ../nixup rpizerotwo1 \
#   --override-input 'tow-boot' "${TOWBOOT}" \
#   --override-input 'nixpkgs' "${NIXPKGS_WORKTREE}"
# ssh cole@"$(tailscale ip --6 rpizerotwo1)" "sudo tow-boot-rpi-update"
