#!/usr/bin/env bash
set -euo pipefail
set -x

data="$(mktemp)"
./gen-bootstrap.sh "${1}" > "${data}"
userdata="$(cat ${data})"

loc="dfw2";  plan="c2.medium.x86";  os="nixos_19_03"; price="0.25"; duration="6 hour";
#loc="ams1";  plan="c2.large.arm";   os="nixos_19_03"; price="0.3"; duration="6 hour";
#loc="sjc1";  plan="c2.large.arm";   os="custom_ipxe"; price="0.3"; duration="6 hour";

projectid="$(gopass show colemickens/packet.net | grep default_project_id | cut -d' ' -f2)"
termtime="$(TZ=UTC date --date="${duration}" --iso-8601=seconds)"
hostname="pkt-$(printf "%x" "$(date '+%s')")"


if [[ "${os}" == "custom_ipxe" ]]; then
  packet device create \
    --hostname "${hostname}" \
    --plan "${plan}" \
    --operating-system "custom_ipxe" \
    --ipxe-script-url "http://907e8786.packethost.net/result/aarch64/netboot.ipxe" \
    --facility "${loc}" \
    --project-id "${projectid}"
  exit 0
fi

packet device create \
  --hostname "${hostname}" \
  --userdata "${userdata}" \
  --plan "${plan}" \
  --operating-system "${os}" \
  --facility "${loc}" \
  --project-id "${projectid}" \
  --spot-instance \
  --spot-price-max "${price}" \
  --termination-time "${termtime}"
