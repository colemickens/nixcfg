#!/usr/bin/env bash

command="$1"; shift

if [[ "${command}" != "build" ]]; then
  exec nix "${command}" "${@}"
fi

buildlog="$(mktemp)"
while true; do
  nix build "${@}" 2> >(tee "${buildlog}" >&2)
  ec=$?
  if [[ "${ec}" == 0 ]]; then
    break
  elif grep "requires non-existent output" "${buildlog}"; then
    echo "[[BUG]]:: nixos/nix#6572 -> retrying!" >&2
    continue
  else
    exit "${ec}"
  fi
done
