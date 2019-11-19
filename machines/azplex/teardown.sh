#!/usr/bin/env bash
set -x

source ./common.sh
az group delete --name "${group}" --yes --no-wait
