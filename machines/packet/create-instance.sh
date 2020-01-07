#!/usr/bin/env bash
set -euo pipefail
set -x

data="$(mktemp)"
./gen-bootstrap.sh "${1}" > "${data}"
userdata="$(cat ${data})"

duration="6 hour"

projectid="$(gopass show colemickens/packet.net | grep default_project_id | cut -d' ' -f2)"
termtime="$(TZ=UTC date --date="${duration}" --iso-8601=seconds)"
hostname="pkt-$(printf "%x" "$(date '+%s')")"

loc="dfw2";  plan="c2.medium.x86";  os="nixos_19_03"; price="0.25"

~/code/packet-cli/bin/packet device create \
  --hostname "${hostname}" \
  --userdata "${userdata}" \
  --plan "${plan}" \
  --operating-system "${os}" \
  --facility "${loc}" \
  --project-id "${projectid}" \
  --spot-instance \
  --spot-price-max "${price}" \
  --termination-time "${termtime}"
