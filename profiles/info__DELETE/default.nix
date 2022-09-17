{ pkgs, lib, config, inputs, ... }:

{
  config = {
    services.getty.autologinUser = "cole";
    environment.loginShellInit = ''
      if [[ "$(tty)" == "/dev/tty1" ]]; then
      while true; do
        ip a
        echo
        systemctl list-units --failed --no-pager | head -n20
        echo
        journalctl -r -u wlan-join.service | head -n20
        sleep 10
        clear
      done
      fi
    '';
  };
}
