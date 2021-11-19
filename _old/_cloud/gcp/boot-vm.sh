#!/usr/bin/env bash
set -euo pipefail
set -x

name="${1}"; shift
img="${1}"; shift

gcloud compute instances create \
  "${name}" \
  --zone="us-west1-b" \
  --machine-type="f1-micro" \
  --subnet="default" \
  --network-tier="PREMIUM" \
  --maintenance-policy="TERMINATE" \
  --no-service-account \
  --no-scopes \
  --image="${img}" \
  --boot-disk-size="30GB" \
  --boot-disk-type="pd-standard" \
  --boot-disk-device-name="${img}-vm-bootdisk" \
  --reservation-affinity="any"
