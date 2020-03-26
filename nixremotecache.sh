#!/usr/bin/env bash

# nix-build: build derivations only
# scp: copy derivations to server
# ssh: env CACHIX_KEY="" build derivation | cachix push

nix-build
