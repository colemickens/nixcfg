#!/usr/bin/env bash
DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
set -euo pipefail

bldr="${1}"; shift
trgt="${1}"; shift
attr="${1}"; shift

BUILD_ID="$(date '+%s')"
gcrootdir="${DIR}/../_builds/${BUILD_ID}/gcroots";
log="${DIR}/../_builds/${BUILD_ID}/log.txt";
mkdir -p "${gcrootdir}"

if [[ "$trgt" == *"cachix:"* ]]; then
  cachix_cache="$(echo "${trgt}" | cut -d ':' -f2)"
  cachix_key="$(cat /run/secrets/cachix_signkey_colemickens)"
fi

## EVAL
nix-eval-jobs \
  --gc-roots-dir "${gcrootdir}" \
  --flake "${attr}"
