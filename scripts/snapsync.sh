#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/stderr 2>&1 && pwd )"

hosts=(
  "rpifour1"
  "rpifour2"
  "rpithreebp1"

  "rpizerotwo1"
  "rpizerotwo2"
  "rpizerotwo3"
)

if [[ "${1-""}" == "" ]]; then
  set -x
  parallel -j$(nproc) --verbose --tag "${DIR}/snapsync.sh" ::: "${hosts[@]}"
  set +x
  exit 0
fi

ssh "cole@$(tailscale ip --6 "${1}")" \
  "sudo systemctl restart systemd-timesyncd; \
    sleep 3; systemctl --user stop snapclient-local; \
    sleep 1; systemctl --user start snapclient-local"
