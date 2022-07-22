#!/usr/bin/env bash

efibootmgr_="$(which efibootmgr)"

set -e
set -x
term=$1

next="$(sudo ${efibootmgr_} | rg --ignore-case "Boot(\d+)\*+ ''${term}.*" -r '$1')"
sudo ${efibootmgr_} --bootnext "$next" >/dev/null

next="$(sudo ${efibootmgr_} | rg --ignore-case "BootNext: (\d+)" -r '$1')"
sudo ${efibootmgr_} | rg "Boot''${next}"
