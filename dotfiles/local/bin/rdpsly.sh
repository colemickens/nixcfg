#!/usr/bin/env bash

set -euo pipefail
set -x

RDPUSER="cole.mickens@gmail.com"
RDPPASS="$(gopass show -o "websites/microsoft.com/cole.mickens@gmail.com")"

RDPHOST="${RDPHOST:-"192.168.1.11"}"

set +x

echo wlfreerdp /p:"********" \
  /u:"${RDPUSER}" /v:"${RDPHOST}" /rfx +fonts /dynamic-resolution /compression-level:2

wlfreerdp /p:"${RDPPASS}" \
  /u:"${RDPUSER}" /v:"${RDPHOST}" /rfx +fonts /dynamic-resolution /compression-level:2
