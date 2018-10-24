#!/usr/bin/env bash
set -x
set -euo pipefail

export STORE="${STORE:-"${HOME}/.nixcache"}" # semi-permanent expensive NARs
export AZURE_STORAGE_CONNECTION_STRING="${AZURE_STORAGE_CONNECTION_STRING:-"$(cat /etc/nixos/secrets/kixstorage-secret)"}"
export CACHE_KEY="${CACHE_KEY:-"/etc/nixos/secrets/nixcache.cluster.lol-1-secret"}"

blobnames="$(mktemp)"
function bloblist() {
  cc="$(az storage container list | jq -r "[ .[] | select(.name==\"nixcache\") ] | length")"
  [[ "${cc}" -eq 0 ]] && az storage container create --name "nixcache" --public-access container
  az storage blob list --container-name "nixcache" | jq -r '.[].name' > "${blobnames}"
}
bloblist &

installables=("${@}")
[[ $# -eq 0 ]] && installables=( "--all" )

nix copy --to "file://${STORE}" "${installables[@]}"
nix sign-paths --store "file://${STORE}" -k "${CACHE_KEY}" "${installables[@]}" --recursive

stagedir=""
if [[ $# -eq 0 ]]; then
  stagedir="${STORE}"
else
  stagedir="$(mktemp -d)"; mkdir -p "${stagedir}/nar"
  set +x
  for p in $(nix-store --query --requisites "${installables[@]}"); do
    pth="$(echo ${p} | cut -d'/' -f4 | cut -d'-' -f1)"
    infopath="${pth}.narinfo"
    narpath="$(cat "${STORE}/${infopath}" | grep 'URL: ' | cut -d' ' -f2)"
    # TODO: why were we even getting dupes here?
    [ ! -e "${stagedir}/${infopath}" ] && ln -s "${STORE}/${infopath}" "${stagedir}/${infopath}"
    [ ! -e "${stagedir}/${narpath}" ] && ln -s "${STORE}/${narpath}"  "${stagedir}/${narpath}"
  done
  set -x
fi

wait

# diff time!
# symlink into ${uploaddir} any paths that are in ${stagedir} but not ${blobnames}
uploaddir="$(mktemp -d)"; mkdir -p "${uploaddir}/nar"
find "${stagedir}" ! -path "${stagedir}" -printf '%P\n'| grep -vFf "${blobnames}" | while read -r pth; do
  ln -s "${stagedir}/${pth}" "${uploaddir}/${pth}"
done

# batch upload
time az storage blob upload-batch \
  --source "${uploaddir}" \
  --destination "nixcache" \

