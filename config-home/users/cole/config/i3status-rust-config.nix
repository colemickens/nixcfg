{ pkgs, ... }:

let
  outputsStatus = pkgs.writeShellScript "outputs-status.sh" ''
  set -euo pipefail
  set -x

  alloutputs="$(swaymsg -t get_outputs)"

  outputnames="$(printf "$alloutputs" | jq -r '.[] | select(.active == true).name')"

  result=""
  while read -r out; do
    scale="$(swaymsg -t get_outputs | jq ".[] | select(.name==\"$out\").scale")"
    printf -v scale "%.01f" "$scale"
    result="$result$out($scale) "
  done < <(echo "$outputnames")

  printf "%s" "$result "
  '';
in pkgs.writeScript "i3status.toml" ''
  theme = "plain"
  icons = "none"

  [[block]]
  block = "custom"
  command = "${outputsStatus}"
  interval = 1

  [[block]]
  block = "backlight"

  [[block]]
  block = "sound"

  [[block]]
  block = "temperature"
  collapsed = false
  interval = 10
  format = "{average}°"

  [[block]]
  block = "cpu"
  frequency = true

  [[block]]
  block = "memory"
  format_mem = "{Mup}%"

  [[block]]
  block = "battery"
  format = "{percentage}% {time}"

  [[block]]
  block = "time"
  format = "%a-%_d %H:%M:%S "
''

