#!/usr/bin/env bash
set -euo pipefail
set -x

R="../.."
h="cole@$(tailscale ip --6 oracular)"
nix build --eval-store "auto" --store "ssh-ng://${h}" \
  "${R}#nixosConfigurations.oracular_kexec.config.system.build.kexec_script"

out="$(nix eval --raw "${R}#nixosConfigurations.oracular_kexec.config.system.build.kexec_script")"

ssh "${h}" "sudo ${out}"

# TODO: what does nix build do in regards to --out-link when store is remote?

# update oracle:
# curl "https://nixos-nix-install-tests.cachix.org/serve/j087w6xqqspfs363449x750x9r0kn31s/install" > install
# chmod +x install
# ./install --tarball-url-prefix https://nixos-nix-install-tests.cachix.org/serve
