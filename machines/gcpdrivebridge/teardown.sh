#!/usr/bin/env bash
set -euo pipefail
set -x

BUCKET_NAME="${BUCKET_NAME:-"colemickens-images"}"

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

if gcloud compute images describe "gcpdrivebridge-img" &>/dev/null; then
  gcloud compute images delete "gcpdrivebridge-img" --quiet
fi
