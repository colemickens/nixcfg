#!/usr/bin/env bash

set -euo pipefail
set -x

IMAGE="microsoft/azure-cli:latest"
#IMAGE="azuresdk/azure-cli-python:2.0.22"

docker pull "${IMAGE}"
docker run -it "${IMAGE}" pip freeze \
    | head -n -2 > requirements.txt

sudo rm -rf /tmp/pypi2nix

sudo pypi2nix -v \
    --python-version "3.6" \
    --extra-build-inputs "gcc" \
    --extra-build-inputs "libffi" \
    --extra-build-inputs "openssl" \
    --setup-requires "wheel" \
    --setup-requires "setuptools" \
    -e wheel \
    -e azure-cli \
        | tee "log.txt"

#    -e azure-cli \


#    --setup-requires "wheel" \

#    --no-default-overrides \
