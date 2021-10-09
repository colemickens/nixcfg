#!/usr/bin/env bash
set -euo pipefail
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/stderr 2>&1 && pwd )"
set +x; source /run/secrets/nixup-secrets; set -x

function packet_script() {
  set +x
  cat "${1}" |
    sed "s#@URL@#${RUNNER_URL:-"UNSET_RUNNER_URL"}#g" |
    sed "s|@RUNNER_TOKEN@|${RUNNER_TOKEN:-"UNSET_RUNNER_TOKEN"}|g" |
    sed "s#@LABEL@#${RUNNER_LABEL:-"UNSET_RUNNER_LABEL"}#g" |
    sed "s|@TAILSCALE_AUTHKEY@|${TAILSCALE_AUTHKEY:-"UNSET_TAILSCALE_AUTHKEY"}|g"
  set -x
}
user_data_file="$(mktemp)"
packet_script ../packet/scripts/nix-unstable.sh > "${user_data_file}"

OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q"

CIDR_BLOCK="192.168.0.0/24"

COMPARTMENT_ID="$(oci iam compartment create \
  --compartment-id "${OCI_TENANCY_OCID}" \
  --name "nixcfg-$(date '+%s')" \
  --description "nixcfg" \
  --wait-for-state "ACTIVE" | jq -rc '.data.id')"

# === x86_64-linux shape
# shape="VM.Standard.E2.1.Micro"
# === aarch64-linux shape
shape="VM.Standard.A1.Flex"
shape_config='{"memoryInGBs":8,"ocpus":1}'

./launch_instance_example.sh \
  up \
  "${shape}" \
  "${shape_config}" \
  "${user_data_file}" \
  "${COMPARTMENT_ID}" \
  "${CIDR_BLOCK}" \
  "/home/cole/.ssh/authorized_keys" | tee /tmp/oci.log
