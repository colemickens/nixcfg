#!/usr/bin/env bash
set -x
set -euo pipefail
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ip="${1}"; shift
hn="${1}"; shift

tmpkey="${DIR}/../../secrets/unencrypted/lukspw-${hn}"
if [[ ! -e "${tmpkey}" ]]; then
  uuidgen | tr -d " \t\n\r" > "${tmpkey}"
  (
    cd "${DIR}/../../secrets"
    ./util.sh e
  )
fi

rb="${DIR}/../rbuild.sh"
instuser="nixos"

if [[ "${installout:-""}" == "" ]]; then
  pushd "${DIR}/../.."
  installout="$("${rb}" "$(tsip6 slynux)" "cachix" "${DIR}/../..#toplevels.${hn}" "${@}")"
  popd
fi

ssh-keygen -R "${ip}"
ssh-keyscan "${ip}" >> ~/.ssh/known_hosts
ssh "${instuser}@${ip}" "mkdir -p .ssh; curl -L 'https://github.com/colemickens.keys' > .ssh/authorized_keys"

scp "${DIR}/inner.sh" "${instuser}@${ip}:/tmp/inner.sh"
scp \
  "${tmpkey}" \
  "${instuser}@${ip}:/tmp/lukspw-${hn}"
  
# -t for the manual luks pw entry
# ssh -t "${instuser}@${ip}" "sudo /tmp/inner.sh diskinit ${hn} ${installout}"
ssh "${instuser}@${ip}" "sudo /tmp/inner.sh install ${hn} ${installout}"

# if [[ "${hn}" == "raisin" ]]; then
#   ssh "${instuser}@${ip}" "sudo efibootmgr --bootorder "
# fi
