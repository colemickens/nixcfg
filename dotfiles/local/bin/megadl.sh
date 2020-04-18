#!/usr/bin/env bash
set -x

u="$(gopass show johndough/mega | rg username | cut -d' ' -f2)"
p="$(gopass show johndough/mega | rg password | cut -d' ' -f2)"

megadl --username "$u" --password "$p" "${@}"
