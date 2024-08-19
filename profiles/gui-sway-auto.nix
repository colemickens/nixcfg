{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  autostarts = {
    # "vkcube" = ''
    #   export VK_INSTANCE_LAYERS='VK_LAYER_MESA_overlay'
    #   ${pkgs.vulkan-tools}/bin/vkcube-wayland
    # '';
    # "glmark2" = ''
    #   "${pkgs.glmark2}/bin/glmark2-wayland" --annotate
    # '';

    "pipes" = ''
      ${pkgs.alacritty}/bin/alacritty -e "${pkgs.pipes-rs}/bin/pipes-rs"
    '';

    # "mpv" = ''
    #   ${pkgs.mpv}/bin/mpv --loop 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
    # '';

    # wezterm doesn't work:
    # wezterm_gui::frontend > Failed to create window ...    # 
  };
in
{
  imports = [
    ../profiles/hm.nix
    ../mixins/pipewire.nix
  ];
  config = {
    services.getty.autologinUser = "cole";
    hardware.graphics.enable = true;

    environment.systemPackages = (
      with pkgs;
      ([
        vulkan-tools
        glxinfo
        # wezterm
        # qt5.qtwayland
        # qt6.qtwayland
      ])
    );

    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        home.sessionVariables = {
          # XDG_SESSION_TYPE = "wayland";
          # WLR_LIBINPUT_NO_DEVICES = "1";
          # WLR_RENDERER = "vulkan";
        };
        wayland.windowManager.sway = {
          enable = true;
          checkConfig = false;
          systemd.enable = true; # beta
          wrapperFeatures = {
            base = false; # this should be the default (dbus activation, not sure where XDG_CURRENT_DESKTOP comes from)
            gtk = true; # I think this is also the default...
          };
          xwayland = false;
          config = {
            bars = [ ];
          };
        };
      };

    environment.loginShellInit = ''
      [[ "$(tty)" == /dev/tty1 ]] && (
        set -x;
        sleep 1;
        export XDG_SESSION_TYPE=wayland
        export WLR_LIBINPUT_NO_DEVICES=1
        # export WLR_RENDERER=vulkan
        exec sway &> $HOME/sway.log
      )
    '';

    systemd.user.services = (
      lib.flip lib.mapAttrs' autostarts (
        n: v: {
          name = "sway-autostart-${n}";
          value = {
            enable = true;
            description = "sway-autostart-${n}";

            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];

            environment = {
              # WAYLAND_DISPLAY = "wayland-1"; # shouldn't be needed
              # the sway startup should've imported WAYLAND_DISPLAY ahead of time
              QT_QPA_PLATFORM = "wayland-egl";
            };
            script = v;
            restartIfChanged = true;
            serviceConfig = {
              Restart = "always";
              RestartSec = 3;
            };
          };
        }
      )
    );
  };
}
