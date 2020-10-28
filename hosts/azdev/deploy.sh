#!/usr/bin/env bash
set -x
set -euo pipefail

export AZURE_LOCATION="westus2"
export AZURE_VM_SIZE="Standard_D4s_v3"
export AZURE_VM_OS_DISK_SIZE="100"

function deploy() {
  (cd ../..; nix flake update --update-input nixos-azure)

  #upstream="github:colemickens/nixos-azure"
  upstream="/home/cole/code/nixos-azure"

  # build the VHD
  nix build "../..#images.azdev" --out-link /tmp/azdev

  # upload the VHD
  export AZURE_GROUP="azdev2020nov"
  img_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020nov/providers/Microsoft.Compute/images/21.03.20201101.dirty.vhd"
  #img_id="$(set -euo pipefail; \
  #  nix shell "${upstream}" --command \
  #    azutil upload /tmp/azdev)"

  # boot a VM
  export AZURE_GROUP="azdev2020x${RANDOM}"
  nix shell "${upstream}" --command \
  azutil boot "${img_id}"

  az vm show -g "${AZURE_GROUP}" -n "${AZURE_GROUP}"

  # unneeded with auto dns label
  #ip="$(az vm list-ip-addresses -n "${name}" -g "${name}" -o tsv \
  #  --query '[0].virtualMachine.network.publicIpAddresses[0].ipAddress')"

  host="${AZURE_GROUP}.${AZURE_LOCATION}.cloudapp.azure.com"

  ssh-keyscan -H "${host}" >> ~/.ssh/known_hosts
  export REMOTE="cole@${host}"

  ~/code/nixcfg/nixup build \
    '.#bundles.x86_64-linux' \
    "${REMOTE}" 'cole@localhost'
}

time deploy
