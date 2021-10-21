#!/usr/bin/env bash

set -euo pipefail
set -x

thing="images.bluephone"
out="colemickens-$(echo "${thing}" | sha256sum | cut -d' ' -f1)"

## check if we eval ok with the update mobile-nixos
result="$(nix eval \
  --raw "/home/cole/code/nixcfg#${thing}" \
  --override-input mobile-nixos ~/code/mobile-nixos)"

## update mobile-nixos, only if necessary
[[ -z $(git -C ~/code/mobile-nixos status -s) ]] \
|| git -C ~/code/mobile-nixos commit . --amend --no-edit \
&& git -C ~/code/mobile-nixos push origin HEAD -f

## update our flake's mobile-nixos
nix flake lock ../.. --update-input mobile-nixos --commit-lock-file

## push
git -C /home/cole/code/nixcfg commit . -m "wip" || true
git -C /home/cole/code/nixcfg push origin HEAD

## pull remote, build
ssh "colemickens@aarch64.nixos.community" "git -C /home/colemickens/code/nixcfg remote update \
  && git -C /home/colemickens/code/nixcfg reset --hard origin/main \
  && nix build -L /home/colemickens/code/nixcfg#${thing} --out-link /tmp/${out}"

nix copy --no-check-sigs --from "ssh-ng://colemickens@aarch64.nixos.community" "${result}"
ssh "colemickens@aarch64.nixos.community" "nix path-info -r $result" > "/tmp/${out}-paths"
ssh "colemickens@aarch64.nixos.community" "rm -f /tmp/${out}"

set +x
cat "/tmp/${out}-paths"
echo; echo; echo
echo "these are your friends: "
cat "/tmp/${out}-paths" | grep "install" | grep ".sh"

if [[ "${1:-""}" == "flash" ]]; then
  script="$(cat "/tmp/${out}-paths" | grep "install" | grep "system" | grep ".sh")"

  ${script}
fi
