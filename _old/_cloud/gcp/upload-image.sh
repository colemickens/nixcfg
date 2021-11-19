#!/usr/bin/env bash
set -euo pipefail
set -x

export BUCKET_NAME="${BUCKET_NAME:-"colemickens-images"}"

image_nix="${1:-"./image.nix"}"

# img + img_name
nix-build "${image_nix}" --out-link "gce"
export img_path=$(echo gce/*.tar.gz)
img_name="$(basename "${img_path}")"
img_name="${img_name%".raw.tar.gz"}"
img_name="${img_name//[._]/-}"

# gcp bucket
if ! gsutil ls "gs://${BUCKET_NAME}" >/dev/null; then
  gsutil mb -c "standard" -l "us-west1" "gs://${BUCKET_NAME}" 
fi

# gcp image
if gcloud compute images describe "${img_name}" &>/dev/null; then
  gcloud compute images delete "${img_name}" --quiet
fi

# gcp upload
uri="gs://${BUCKET_NAME}/${img_name}.tar.gz"
if ! gsutil ls "${uri}"; then
  gsutil cp "${img_path}" "${uri}"
fi

# gcp image
gcloud compute images create \
  "${img_name}" \
  --source-uri="${uri}"

gcloud compute images describe \
  "${img_name}"
