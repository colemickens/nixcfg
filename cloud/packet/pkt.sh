
#! /usr/bin/env bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/stderr 2>&1 && pwd )"
set +x; source /run/secrets/nixup-secrets; set -x
cd "${DIR}"

function packet_wait() {
  dev="${1}"
  set +x; echo -n "waiting for "${dev}" to finish provisioning."
  while true; do
    status="$(metal device get --output 'json' --search "${1}" | jq -r '.[0].state')"
    if [[ "${status}" != "provisioning" && "${status}" != "queued" ]]; then break; fi
    echo -n "."; sleep 2
  done; echo " done!"; set -x
  ip="$(metal device get --output 'json' --search "${1}" | jq -r '.[0].ip_addresses[] | select((.address_family==4) and (.public==true)).address')"
  ssh-keygen -R "${ip}"
  ssh-keyscan -H "${ip}" >> ~/.ssh/known_hosts

  echo "nix build --store 'ssh-ng://${ip}' .#bundles.x86_64-linux --eval-store auto --builders-use-substitutes"
}

function packet_script() {
  set +x
  cat "${1}" |
    sed "s#@URL@#${RUNNER_URL:-"UNSET_RUNNER_URL"}#g" |
    sed "s|@RUNNER_TOKEN@|${RUNNER_TOKEN:-"UNSET_RUNNER_TOKEN"}|g" |
    sed "s#@LABEL@#${RUNNER_LABEL:-"UNSET_RUNNER_LABEL"}#g" |
    sed "s|@TAILSCALE_AUTHKEY@|${TAILSCALE_AUTHKEY:-"UNSET_TAILSCALE_AUTHKEY"}|g"
  set -x
}

function packet_up_script() {
  machinename="${1}"
  plan="${2}"
  os="${3}"
  script="${4}"

  duration="1 hour";
  termtime="$(TZ=UTC date --date="${duration}" --iso-8601=seconds)"

  facility="sjc1"
  outscr="$(mktemp)"
  packet_script "${script}" > "${outscr}"
  metal device create \
    --hostname "${machinename}" \
    --plan "${plan}" \
    --facility "${facility}" \
    --operating-system "${os}" \
    --spot-instance --spot-price-max "0.5" \
    --termination-time="${termtime}" \
    --userdata-file "${outscr}"

    # --operating-system "custom_ipxe" \
    # --ipxe-script-url "http://907e8786.packethost.net/result/aarch64/netboot.ipxe" \

  time packet_wait "${machinename}"
}

# packet bills by hour, so we always schedule spot instances for just an hour
# (these are picked to boot fast)
function up_nix_x64() { packet_up_script "bldr-x86" "c2.medium.x86"   "ubuntu_18_04" "./scripts/nix-unstable.sh"; }
function up_nix_a64() { packet_up_script "bldr-a64" "c2.large.arm" "ubuntu_18_04" "./scripts/nix-unstable.sh"; }

if [[ ! -z "${1:-""}" ]]; then cmd="${1}"; shift; fi
if [[ -z "${cmd:-""}" ]]; then
  cmd="up"
fi

set -x
"${cmd}" "${@}"
set +x
echo -e "\nexit=$?"
exit 0




# ## <ci-packet> #################################################

# function packet-curl() { curl -H "X-Auth-Token: ${METAL_AUTH_TOKEN}" "$@" 2>/dev/null; }
# function packet-spot() { packet-curl "https://api.packet.net/market/spot/prices" | jq ".spot_market_prices | keys[] as \$k | \"\(\$k) \(.[\$k][\"${1}\"].price)\"" | grep -v null; }
# function packet-up() {
#   packet-up-int "gha-x64" "c2.medium.x86"
#   packet-up-int "gha-arm64" "c2.large.arm"
# }
# function packet-down() {
#   packet-down-int 'gha-x64'
#   packet-down-int 'gha-arm64'
# }
# function packet-up-int() {
#   dev="${1}"
#   plan="${2}"
#   # TODO: find best facility for price+size
#   token_x64="$(gh api -X POST /repos/cole-mickens/nixcfg/actions/runners/registration-token | jq -r .token)"
#   token_arm64="$(gh api -X POST /repos/cole-mickens/nixcfg/actions/runners/registration-token | jq -r .token)"

#   duration="1 hour";
#   termtime="$(TZ=UTC date --date="${duration}" --iso-8601=seconds)"

#   packet-down-int "${dev}"
#   facility="sjc1"
#   script="$(mktemp)"
#   packet-script "${dev}" "${token_x64}" > "${script}"
#   metal device create \
#     --hostname "${dev}" \
#     --plan "${plan}" \
#     --facility "${facility}" \
#     --operating-system "ubuntu_18_04" \
#     --spot-instance --spot-price-max "0.5" \
#     --termination-time="${termtime}" \
#     --userdata-file "${script}"

#   echo packet-wait "${dev}"
# }
# function packet-wait() {
#   dev="${1}"
#   set +x; echo -n "waiting for "${dev}" to finish provisioning."
#   while true; do
#     status="$(metal device get --output 'json' --search "${1}" | jq -r '.[0].state')"
#     if [[ "${status}" != "provisioning" && "${status}" != "queued" ]]; then break; fi
#     echo -n "."; sleep 2
#   done; echo " done!"; set -x
#   ip="$(metal device get --output 'json' --search "${1}" | jq -r '.[0].ip_addresses[] | select((.address_family==4) and (.public==true)).address')"
#   ssh-keygen -R "${ip}"
#   ssh-keyscan -H "${ip}" >> ~/.ssh/known_hosts

#   # wait for runner
#   set +x; echo "waiting for ${dev} runner."
#   while true; do
#     runnerid="$(gh api repos/cole-mickens/nixcfg/actions/runners | jq -r ".runners[] | select (.name == \"${dev}\").id")"
#     if [[ "${runnerid:-""}" != "" ]]; then break; fi
#     echo "waiting for ${dev} runner, waiting..."; sleep 10
#   done; echo " done!"; set -x
# }
# function packet-down-int() {
#   dev="${1}"
#   id="$(metal device get --search "${dev}" --output json | jq -r '.[].id' || true)"
#   if [[ "${id:-""}" != "" ]]; then
#     echo "deleting ${dev}: ${id}, waiting..."; set +x
#     while ! metal device delete --force --id "${id}" &>/dev/null; do echo "deleting ${dev}: ${id}, waiting..."; sleep 10; done; set -x
#   fi
#   runnerid="$(gh api repos/cole-mickens/nixcfg/actions/runners | jq -r ".runners[] | select (.name == \"${dev}\").id")"
#   if [[ "${runnerid:-""}" != "" ]]; then
#     gh api -X DELETE "repos/cole-mickens/nixcfg/actions/runners/${runnerid}" | jq
#   fi
# }
# ## </ci-packet> #################################################
