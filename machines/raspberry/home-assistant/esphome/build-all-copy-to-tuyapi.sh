#! /usr/bin/env nix-shell
#! nix-shell -I nixpkgs=/home/cole/code/nixpkgs -i bash -p esphome

set -euo pipefail
set -x

rm -rf ./out
mkdir -p ./out

for f in *.yaml; do
  dev="$(basename $f .yaml)"
  esphome $f compile
  cp ./$dev/.pioenvs/$dev/firmware.bin ./out/firmware-$dev.bin
done

scp -r ./out/ pi@raspberrypi:/home/pi/firmwares
