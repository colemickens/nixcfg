#!/usr/bin/env bash
set -euo pipefail
set -x

OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q"

CIDR_BLOCK="192.168.0.0/24"

COMPARTMENT_ID="$(oci iam compartment create \
  --compartment-id "${OCI_TENANCY_OCID}" \
  --name "nixcfg-$RANDOM" \
  --description "nixcfg" \
  --wait-for-state "ACTIVE" | jq -rc '.data.id')"

# === x86_64-linux shape
# shape="VM.Standard.E2.1.Micro"
# === aarch64-linux shape
shape="VM.Standard.A1.Flex"
shape_config='{"memoryInGBs":8,"ocpus":4}'

user_data_file="$(mktemp)"
cat ./oci-cloudinit.yaml > "${user_data_file}"

./launch_instance_example.sh \
  up \
  "${shape}" \
  "${shape_config}" \
  "${user_data_file}" \
  "${COMPARTMENT_ID}" \
  "${CIDR_BLOCK}" \
  "/home/cole/.ssh/authorized_keys" | tee /tmp/oci.log
