#!/usr/bin/env bash

set -x
set -euo pipefail

remote="runner@rendezvous.namespace.so"
nixremote="ssh-ng://${remote}"

nixsshopts=("-p" "39073")
export NIX_SSHOPTS="${nixsshopts[@]}"
export SSH_AUTH_SOCK="/var/run/com.apple.launchd.yglq3pjw10/Listeners"

overrides=(
  --inputs-from .
  --override-input nixpkgs-riscv ~/code/nixpkgs__riscv
  --override-input determinate ~/work/code/determinate
  --override-input determinate/determinate-nixd ~/work/code/determinate-nixd
  --override-input determinate/determinate-nixd/fenix ~/work/code/fenix
  --override-input determinate/nix ~/work/code/nix-src
  --override-input determinate/nixpkgs nixpkgs-riscv
)

drv1="$(nix eval --raw "${overrides[@]}" ".#toplevels.jupitertwo.drvPath")"

nix copy --to "${nixremote}" --derivation --no-check-sigs "${drv1}"

cat /nix/var/determinate/netrc \
  | ssh "${nixsshopts[@]}" "${remote}" \
    'sudo tee /nix/var/determinate/netrc'
ssh "${nixsshopts[@]}" "${remote}" sudo mv /tmp/netrc /nix/var/determinate/netrc

ssh "${nixsshopts[@]}" "${remote}" \
  nix build -L --keep-going --keep-failed --print-out-paths --option netrc-file /nix/var/determinate/netrc --extra-substituters \'https://cache.flakehub.com https://edge.cache.flakehub.com/\' --extra-trusted-public-keys \'cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y=\' "${drv1}^*"
