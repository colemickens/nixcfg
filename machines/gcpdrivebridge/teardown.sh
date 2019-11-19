#!/usr/bin/env bash
set -euo pipefail
set -x

source ./common.sh

if gsutil ls "gs://${BUCKET_NAME}" &>/dev/null; then
  gsutil rm -r "gs://${BUCKET_NAME}"
fi

if gcloud compute instances describe &>/dev/null \
  --zone="us-west1-b" "gcpdrivebridge-vm";
then
  gcloud compute instances delete \
    "gcpdrivebridge-vm" \
    --zone="us-west1-b" \
    --delete-disks="all" \
    --quiet
fi

fallback=$(echo gce/*.tar.gz)
fallback="$(basename "${fallback}")"
fallback="${fallback%".raw.tar.gz"}"
fallback="${fallback//[._]/-}"

img_name="${1:-"${fallback}"}"

if gcloud compute images describe "${img_name}" &>/dev/null; then
  gcloud compute images delete "${img_name}" --quiet
fi
