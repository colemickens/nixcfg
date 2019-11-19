#!/usr/bin/env bash
set -euo pipefail
set -x

source ./common.sh

if ! gsutil ls "gs://${BUCKET_NAME}" >/dev/null; then
  gsutil mb -c "standard" -l "us-west1" gs://colemickens-images
fi

bld="$(nix-build ../../default.nix -A gcpdrivebridge --out-link gce)"
source ./common.sh #reload the img_name/img_path
uri="gs://${BUCKET_NAME}/${img_name}"
if ! gsutil ls "${uri}"; then
  gsutil cp "${img_path}" "${uri}"
fi

img_name="${img_name%".raw.tar.gz"}"
img_name="${img_name//[._]/-}"

gcloud compute images create \
  "${img_name}" \
  --source-uri="${uri}"

echo "${uri}"
