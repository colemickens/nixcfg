#!/usr/bin/env bash
set -euo pipefail
set -x

pw="$(gopass show "misc/bitlocker_${1}" | grep recovery | cut -d' ' -f2)"
sudo ydotool sleep 2000 , type "${pw}" , key KEY_ENTER
