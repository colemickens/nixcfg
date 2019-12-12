#!/usr/bin/env bash
set -euo pipefail
set -x

data="$(mktemp)"
./gen-bootstrap.sh > "${data}"
userdata="$(cat ${data})"

projectid="$(gopass show colemickens/packet.net | grep default_project_id | cut -d' ' -f2)"
termtime="$(TZ=UTC date --date="2 hour" --iso-8601=seconds)"
hostname="pkt-$(printf "%x" "$(date '+%s')")"

#configurations:
# loc="dfw2";  plan="g2.large.x86";    price="2";
  loc="sjc1";  plan="m2.xlarge.x86";   price="0.50"
  loc="sjc1";  plan="x2.xlarge.x86";   price="0.50"

~/code/packet-cli/bin/packet device create \
  --hostname "${hostname}" \
  --userdata "${userdata}" \
  --plan "${plan}" \
  --operating-system "nixos_19_03" \
  --facility "${loc}" \
  --project-id "${projectid}" \
  --spot-instance \
  --spot-price-max "${price}" \
  --termination-time "${termtime}"
