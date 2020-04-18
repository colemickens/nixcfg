#!/usr/bin/env bash

if [[ "$LAUNCHER_USE_X11" == "1" ]]; then
  set -- "env GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb"
fi

compgen -c \
  | sort -u \
  | fzf --no-extended --print-query \
  | tail -n1 \
  | xargs -r swaymsg -t command exec "${@}"

