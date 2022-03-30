#!/usr/bin/env bash
set -x
set -euo pipefail
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ip="${1}"; shift
host="${1}"; shift

rb="${DIR}/../rbuild.sh"
instuser="nixos"

if [[ "${installout:-""}" == "" ]]; then
  pushd "${DIR}/../.."
  installout="$("${rb}" "$(tsip6 porty)" "cachix" "${DIR}/../..#toplevels.${host}" "${@}")"
  popd
fi

ssh-keygen -R "${ip}"
ssh-keyscan "${ip}" >> ~/.ssh/known_hosts
ssh "${instuser}@${ip}" "mkdir -p .ssh; curl -L 'https://github.com/colemickens.keys' > .ssh/authorized_keys"

scp "${DIR}/inner.sh" "${instuser}@${ip}:/tmp/inner.sh"
scp "/tmp/lukspw" "${instuser}@${ip}:/tmp/lukspw"

ssh "${instuser}@${ip}" "sudo /tmp/inner.sh ${host} ${installout}"

# if [[ "${host}" == "raisin" ]]; then
#   ssh "${instuser}@${ip}" "sudo efibootmgr --bootorder "
# fi
