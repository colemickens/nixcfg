#!/usr/bin/env bash
set -euo pipefail
set -x

source ./common.sh

gcloud compute instances create \
  "gcpdrivebridge-vm" \
  --zone="us-west1-b" \
  --machine-type="f1-micro" \
  --subnet="default" \
  --network-tier="PREMIUM" \
  --maintenance-policy="TERMINATE" \
  --no-service-account \
  --no-scopes \
  --image="${img_name}" \
  --boot-disk-size="30GB" \
  --boot-disk-type="pd-standard" \
  --boot-disk-device-name="gcpdrivebridge-vm-bootdisk" \
  --reservation-affinity="any"
