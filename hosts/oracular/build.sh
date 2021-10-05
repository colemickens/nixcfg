#!/usr/bin/env bash
set -euo pipefail
set -x

R="../.."
h="opc@132.226.31.59"
nix copy --to "ssh-ng://${h}" "${R}#toplevels.oracular_kexec"
nix build --store "ssh-ng://${h}" "${R}#images.oracular_kexec"

# update oracle:
# curl "https://nixos-nix-install-tests.cachix.org/serve/j087w6xqqspfs363449x750x9r0kn31s/install" > install
# chmod +x install
# ./install --tarball-url-prefix https://nixos-nix-install-tests.cachix.org/serve