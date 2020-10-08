#!/usr/bin/env bash
set -x
set -euo pipefail

export AZURE_GROUP="azdev2020${RANDOM}"
export AZURE_VM_SIZE="Standard_D64s_v3"
export AZURE_VM_OS_DISK_SIZE="512"

(cd ../..; nix flake update --update-input nixos-azure)

#upstream="github:colemickens/nixos-azure"
upstream="/home/cole/code/nixos-azure"

# build the VHD
nix build "../..#hosts.azdev" --out-link /tmp/azdev

# upload the VHD
img_id="$(set -euo pipefail; nix shell "${upstream}" --command azutil upload /tmp/azdev)"

# boot a VM
nix shell "${upstream}" --command azutil boot "${img_id}"
