#!/usr/bin/env bash
set -x
set -euo pipefail

export AZURE_VM_SIZE="Standard_D4s_v3"
export AZURE_VM_OS_DISK_SIZE="100"

(cd ../..; nix flake update --update-input nixos-azure)

#upstream="github:colemickens/nixos-azure"
upstream="/home/cole/code/nixos-azure"

# build the VHD
#nix build "../..#hosts.azdev" --out-link /tmp/azdev

# upload the VHD
export AZURE_GROUP="azdev2020img"
img_id="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020img/providers/Microsoft.Compute/images/21.03.20201007.dirty.vhd"
#img_id="$(set -euo pipefail; nix shell "${upstream}" --command azutil upload /tmp/azdev)"

# boot a VM
export AZURE_GROUP="azdev2020x${RANDOM}"
nix shell "${upstream}" --command azutil boot "${img_id}"

# TODO: get IP, preadd:
# ssh-keyscan -H <ip-address> >> ~/.ssh/known_hosts
