#!/usr/bin/env bash

gopass ls --flat \
  | fzf \
  | xargs -r gopass "${@}" \
  | head -n1 \
  | cut -d' ' -f1 \
  | xargs -r printf "'%s'"

