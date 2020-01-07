#!/usr/bin/env bash

# usage: import-gsettings <gsettings key>:<settings.ini key> <gsettings key>:<settings.ini key> ...

echo "***"
echo "$(date)"
echo "$(GSETTINGS_BACKEND=dconf gsettings get org.gnome.desktop.interface cursor-theme 2>&1)"
echo $XDG_DATA_DIRS
echo "***"

expression=""
for pair in "$@"; do
    IFS=:; set -- $pair
    expressions="$expressions -e 's:^$2=(.*)$:gsettings set org.gnome.desktop.interface $1 \1:e'"
done
IFS=
echo eval exec sed -E $expressions "${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini
eval exec sed -E $expressions "${XDG_CONFIG_HOME:-$HOME/.config}"/gtk-3.0/settings.ini >/dev/null
