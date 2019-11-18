#!/usr/bin/env bash
set -euo pipefail
set -x

BUCKET_NAME="${BUCKET_NAME:-"colemickens-images"}"

group="azplex"
location="westus2"
./az.sh group create --name "${group}" --location "${location}"

diskname="azplex-disk"
./az.sh disk create \
  --resource-group "${group}" \
  --name "${diskname}" \
  --size-gb "${size}" \
  --for-upload true

timeout=$(( 60 * 60 )) # disk access token timeout
sasurl="$(\
  ./az.sh disk grant-access \
    --access-level Write \
    --resource-group "${group}" \
    --name "${diskname}" \
    --duration-in-seconds ${timeout} \
      | jq -r '.accessSas'
)"

azcopy copy "${source}" "${sasurl}" \
  --blob-type PageBlob 
  
./az.sh disk revoke-access \
  --resource-group "${group}" \
  --name "${diskname}"

diskid="$(./az.sh disk show -g "${group}" -n "${diskname}" -o json | jq -r .id)"

./az.sh image create \
  --resource-group "${group}" \
  --name "${diskname}" \
  --source "${diskid}" \
  --os-type "linux" >/dev/null

imageid="$(./az.sh image show -g "${group}" -n "${diskname}" -o json | jq -r .id)"

echo "${imageid}"
