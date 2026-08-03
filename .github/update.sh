#!/usr/bin/env bash
set -x
set -euo pipefail

git switch main-next-wip
git reset --hard origin/main

mkdir -p /tmp/nixpkgs-ci
pushd /tmp/nixpkgs-ci
###

# 1. Initialize an empty repository
git init /tmp/nixpkgs-ci

# 2. Add remotes and restrict them to ONLY the branches you care about
git remote add origin git@github.com:colemickens/nixpkgs
# uh, somehow this was waaaay slower:
# git remote add origin https://github.com/colemickens/nixpkgs
# git remote set-url --push origin git@github.com:colemickens/nixpkgs

git config remote.origin.promisor true
git remote set-branches origin \
  colemickens/wip/nixos-unstable \
  colemickens/wip/nixpkgs-unstable \
  colemickens/nixos-unstable \
  colemickens/nixpkgs-unstable

git remote add nixos https://github.com/NixOS/nixpkgs.git
git config remote.nixos.promisor true
git remote set-branches nixos nixos-unstable nixpkgs-unstable

# 3. Fetch all remotes using the blobless filter
git fetch --filter=blob:none origin
git fetch --filter=blob:none nixos

# 4. Colocate Jujutsu so it can read the git refs
jj git init --colocate

# 5. Set up local bookmarks (branches) pointing to your origin tracking branches
# Note: If you are using a jj version older than 0.16, replace `bookmark` with `branch`
jj bookmark track colemickens/wip/nixos-unstable --remote origin
jj bookmark track colemickens/wip/nixpkgs-unstable --remote origin
jj bookmark track colemickens/nixos-unstable --remote origin
jj bookmark track colemickens/nixpkgs-unstable --remote origin

# 6. Rebase (Note the `-d` flag required for the destination in recent jj versions)
jj rebase -b colemickens/nixos-unstable -d nixos-unstable@nixos
jj rebase -b colemickens/nixpkgs-unstable -d nixpkgs-unstable@nixos
jj bookmark set colemickens/wip/nixos-unstable -r colemickens/nixos-unstable
jj bookmark set colemickens/wip/nixpkgs-unstable -r colemickens/nixpkgs-unstable

# 7. Push explicitly to avoid pushing unintended local state
jj git push --remote origin -b colemickens/wip/nixos-unstable -b colemickens/wip/nixpkgs-unstable

###############################################################################
popd

nix flake update \
  --override-input cmpkgs github:colemickens/nixpkgs?ref=colemickens/wip/nixos-unstable \
  --override-input nixpkgs-unstable github:colemickens/nixpkgs?ref=colemickens/wip/nixpkgs-unstable \
  --commit-lock-file

if git diff --exit-code HEAD origin/main-next-wip; then
  echo "no material flake.lock diff"
  echo "abandoning"
  exit 0
fi

# we want to push as colebot tho
git remote set-url --push origin git@github.com:colemickens/nixcfg
git push --force-with-lease origin main-next-wip
