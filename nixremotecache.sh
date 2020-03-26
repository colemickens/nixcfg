#!/usr/bin/env bash
set -x
set -euo pipefail

remote="colemickens@aarch64.nixos.community"
cachixkey="$(gopass show websites/cachix.org/gh | grep cachix_key_colemickens | cut -d' ' -f2)"

# nix-build: build derivations only
# scp: copy derivations to server
# ssh: env CACHIX_KEY="" build derivation | cachix push

drv="$(nix-instantiate -A rpiboot)"

# you know what, NO, I'm not using
# nix-copy-closure
# this ssh crap is just.. no. no. horrible ux
# this pisses me off even tho I'm a huge nixos dork

# instead, use an old trick, copy to a new local store
# rsync that up instead
# avoid this problem entirely

# TODO: as always, also constantly wonder if I should've
# used the 2.0 CLI instead, despite its own probs.
# TODO2: and of course, now I am because I can't
#  remember how to get nix-copy-closure to do it.
#dst="$(mktemp -d)"
dst="/tmp/storetmp"
#nix-copy-closure --to "file://${dst}" "${drv}"
nix copy --to "file://${dst}" "${drv}"

remotetmp="$(ssh "${remote}" mkdir -p "${dst}")"
rsync -avh "${dst}/" "${remote}:${dst}"

ssh "${remote}" "nix copy --experimental-features 'nix-command ca-references' --from \"file://${dst}\" \"${drv}\""
ssh "${remote}" "env CACHIX_KEY=\"${cachixkey}\" nix-build ${drv} | cachix push"

ssh "${remote}" "rm -rf '${dst}'"
ssh "${remote}" "nix-store --delete -r '${drv}'"
