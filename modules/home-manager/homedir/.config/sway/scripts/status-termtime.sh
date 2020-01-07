#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
packet="${HOME}/code/packet-utils/packet.sh"

{
    sleep 5
    kill $$
} &

DEVICES_OUT="$("${packet}" device_list)"
DEVICE_HOSTNAMES="$(echo "${DEVICES_OUT}" | jq -r ".[].hostname")"

for RECORD in ${DEVICE_HOSTNAMES}; do
  TERMTIME="$("${packet}" device_termination_time "${RECORD}")"
  DEVICE="$(echo "${DEVICES_OUT}" | jq -r ".[] | select(.hostname==\"${RECORD}\")")"
  PLAN="$(echo "${DEVICE}" | jq -r ".plan.slug")"
  CREATED="$(echo "${DEVICE}" | jq -r ".created_at")"
  CREATED="$(date -d "${CREATED}" '+%s')"
  NOW="$(date '+%s')"
  PRICE="$(echo "${DEVICE}" | jq -r ".spot_price_max")"
  set -x
  UPTIME="$(( ${NOW} - ${CREATED} ))"
  UPTIME_HOURS="$(echo "scale=2; ${UPTIME} / (60*60)" | bc -l)"
  COST="$(echo "scale=2; ${UPTIME_HOURS} * ${PRICE}" | bc -l)"
  set +x
  output="${output}(${RECORD}: \$${COST} T-${TERMTIME})"
done

# TODO UPTIME PRETTY, we used to have something for this (Term time does ths???)

if [[ ! -z "${output}" ]]; then
  echo "PKT ${output}"
else
  echo "NO PKT"
fi

