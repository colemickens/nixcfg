#!/usr/bin/env bash
set -euo pipefail

t="$(mktemp)"
curl -L "$1.patch" > "$t"
~/code/nixcfg/misc/jj-am.sh "$t"
