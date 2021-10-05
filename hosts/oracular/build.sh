#!/usr/bin/env bash

R="../.."
h="opc@132.226.31.59"
nix copy --to "ssh-ng://${h}" "${R}#toplevels.oracular_kexec"
nix build --store "ssh-ng://${h}" "${R}#images.oracular_kexec"
