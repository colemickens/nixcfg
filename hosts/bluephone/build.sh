#!/usr/bin/env bash

set -euo pipefail
set -x

thing="images.bluephone"
result="$(nix eval --raw "/home/cole/code/nixcfg#${thing}")"
out="colemickens-$(echo "${thing}" | sha256sum | cut -d' ' -f1)"

git -C /home/cole/code/nixcfg commit . -m "wip" || true; git -C /home/cole/code/nixcfg push origin HEAD
ssh "colemickens@aarch64.nixos.community" "git -C /home/colemickens/code/nixcfg remote update"
ssh "colemickens@aarch64.nixos.community" "git -C /home/colemickens/code/nixcfg reset --hard origin/main"
ssh "colemickens@aarch64.nixos.community" "nix build -L /home/colemickens/code/nixcfg#${thing} --out-link /tmp/${out}"

nix copy --no-check-sigs --from "ssh-ng://colemickens@aarch64.nixos.community" "${result}"
ssh "colemickens@aarch64.nixos.community" "nix path-info -r $result"
ssh "colemickens@aarch64.nixos.community" "rm -f /tmp/${out}"
