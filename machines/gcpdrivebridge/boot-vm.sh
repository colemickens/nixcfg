#!/usr/bin/env bash
set -euo pipefail
set -x

fallback=$(echo gce/*.tar.gz)
fallback="$(basename "${fallback}")"
fallback="${fallback%".raw.tar.gz"}"
fallback="${fallback//[._]/-}"

img_name="${1:-"${fallback}"}"

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

exit 0

gcloud compute instance create \
  "gcpdrivebridge" \
  --image-name "gcpdrivebridge" \
  --maintenance-policy="TERMINATE" \
  --machine-type="f1-micro"
  --boot-disk-size="30GB"

