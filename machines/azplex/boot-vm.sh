#!/usr/bin/env bash
set -euo pipefail
set -x

BUCKET_NAME="${BUCKET_NAME:-"colemickens-images"}"

img_path=$(echo gce/*.tar.gz)
img_name=${IMAGE_NAME:-$(basename "$img_path")}

gcloud compute images create \
  "gcpdrivebridge-img" \
  --source-uri="gs://${BUCKET_NAME}/${img_name}"

gcloud compute instances create \
  "gcpdrivebridge-vm" \
  --zone="us-west1-b" \
  --machine-type="f1-micro" \
  --subnet="default" \
  --network-tier="PREMIUM" \
  --maintenance-policy="TERMINATE" \
  --no-service-account \
  --no-scopes \
  --image="gcpdrivebridge-img" \
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

