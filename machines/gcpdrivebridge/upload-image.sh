#!/usr/bin/env bash
set -euo pipefail
set -x

BUCKET_NAME="${BUCKET_NAME:-"colemickens-images"}"

#if ! gsutil acl get "gs://${BUCKET_NAME}" >/dev/null; then
if ! gsutil ls "gs://${BUCKET_NAME}" >/dev/null; then
  gsutil mb -c "standard" -l "us-west1" gs://colemickens-images
fi

bld="$(nix-build ../../default.nix -A gcpdrivebridge --out-link gce)"
img_path=$(echo gce/*.tar.gz)
img_name=${IMAGE_NAME:-$(basename "$img_path")}
uri="gs://${BUCKET_NAME}/${img_name}"
img_id=$(echo "$img_name" | sed 's|.raw.tar.gz$||;s|\.|-|g;s|_|-|g')
if ! gsutil ls "${uri}"; then
  gsutil cp "$img_path" "${uri}"
fi

img_name="${img_name%".raw.tar.gz"}"
img_name="${img_name//[._]/-}"
echo $img_name

gcloud compute images create \
  "${img_name}" \
  --source-uri="${uri}"

echo "${uri}"
