{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  prefs = import ./_preferences.nix { inherit pkgs lib config inputs; };

  waylandHosts = [
    "rpithreebp1"
    "rpifour1"
    "rpifour2"
  ];

  # sway_cava = pkgs.writeShellScript "startup" ''
  #   set -x
  #   logdir="$HOME/$(cat  /proc/sys/kernel/random/boot_id)"; mkdir -p $logdir
  #   sleep 3
  #   systemctl --user restart snapclient-local # TODO THIS IS A HACK
  #   sleep 1
  # '';
  reset-audio = pkgs.writeShellScriptBin "reset-audio" ''
    set -x
    ${pkgs.systemd}/bin/systemctl --user restart pipewire pipewire-pulse
    sleep 2
    ${pkgs.systemd}/bin/systemctl --user restart snapclient-local
  '';

  # <sway config>
  out_rpi4_lgc165 = "LG Electronics LG TV SSCR2 0x00000101";
  out_rpi3b_sony55 = "HDMI-A-1";
  out_rpi021_denon = "DENON, Ltd. DENON-AVR 0x00000101";
  # </sway config>
in
{
  config = {
    nixpkgs.overlays = [
      inputs.nixpkgs-wayland.overlay
    ];

    services.getty.autologinUser = "cole";

    home-manager.users.cole = { pkgs, ... }@hm: {
      home.packages = with pkgs; [
        mpv
        v4l-utils
        wezterm
        foot
        gst_all_1.gstreamer
        gst_all_1.gstreamer.dev
        qt5.qtwayland
      ];

      # this is what projectM-pulseaudio uses?
      systemd.user.services.visualizer = {
        Unit = {
          Description = "Visualizer";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          Environment = [
            "WAYLAND_DISPLAY=wayland-1"
          ];
          ExecStart = (pkgs.writeShellScript "foot-cava.sh" ''
            "${pkgs.foot}/bin/foot" "${pkgs.cli-visualizer}/bin/vis"
          '').outPath;
          # ExecStart = "${pkgs.projectm}/bin/projectMSDL";
          # ExecStart = "${pkgs.projectm}/bin/projectM-pulseaudio";
          Restart = "always";
          RestartSec = 3;
        };
        Install = { WantedBy = [ "sway-session.target" ]; };
      };

      # home.file.".projectM/config.inp".text = ''
      #   Aspect Correction = 1
      #   Easter Egg Parameter = 1
      #   FPS = 60
      #   Fullscreen = true
      #   Hard Cut Sensitivity = 1
      #   Menu Font = VeraMono.ttf
      #   Mesh X = 220
      #   Mesh Y = 125
      #   Preset Duration = 30
      #   Preset Path = ${pkgs.projectm}/share/projectM/presets
      #   Shuffle Enabled = 1
      #   Smooth Preset Duration = 5
      #   Smooth Transition Duration = 5
      #   Soft Cut Ratings Enabled = 0
      #   Texture Size = 512
      #   Title Font = Vera.ttf
      #   Window Height = 600
      #   Window Width = 800
      # '';
      xdg.enable = true;
      wayland.windowManager.sway = {
        enable = true;
        systemdIntegration = true;
        wrapperFeatures = {
          base = true;
          gtk = true;
        };
        xwayland = false;
        extraConfig = (lib.optionalString (prefs.cursor != null) ''
          seat seat0 xcursor_theme "${prefs.cursor.name}" ${builtins.toString prefs.cursorSize}
        '');
        config = rec {
          modifier = "Mod4";
          focus.followMouse = "always";
          output = {
            "*" = {
              # mode = "1920x1080@30.000Hz";
              mode = "1280x720@30.000Hz";
            };
            # "${out_rpi4_lgc165}" = {
            #   mode = "1920x1080@60.000Hz";
            #   # mode = "1920x1080@120.000Hz";
            #   # mode = "3840x2160@50.000Hz";
            # };
            # "${out_rpi3b_sony55}" = {
            #   mode = "1920x1080@60.000Hz";
            # };
            # "${out_rpi021_denon}" = {
            #   mode = "1920x1080@60.000Hz";
            # };
          };
          bars = [ ];
          window = {
            border = 0;
            titlebar = false;
          };
          # startup = [{ command = snapclient-restart.outPath; }];
          keybindings = {
            "${modifier}+Return" = "exec ${prefs.default_term}";
          };
        };
      };
      programs.zsh = {
        profileExtra = ''
          set -x
          
          loginctl list-sessions
          echo $XDG_SESSION_DIR
            
          if [[ "$(tty)" == "/dev/tty1" ]]; then
            logdir="$HOME/$(cat  /proc/sys/kernel/random/boot_id)"; mkdir -p $logdir
            ln -sfT $logdir $HOME/logs
            dmesg &> $logdir/dmesg-boot.log
            
            # export WLR_RENDERER=vulkan # not foreign_family extension
            export WLR_NO_HARDWARE_CURSORS=1
            export WLR_LIBINPUT_NO_DEVICES=1
            systemctl --user import-environment WLR_NO_HARDWARE_CURSORS
            systemctl --user import-environment WLR_LIBINPUT_NO_DEVICES
            
            sleep 3
            loginctl list-sessions
            
            sleep 3
            "${reset-audio}/bin/reset-audio"
            
            echo $XDG_SESSION_DIR
            systemctl --user show-environment | grep XDG_SESSION
            
            case "$(hostname)" in
              "rpifour"* | "rpithree"* | "rpizerotwo"* )
                xsway
              ;;
              # "rpizerotwo1" | "rpizerotwo2" | "rpizerotwo3" )
              #   # cava &> $logdir/cava.log
              #   vis &> $logdir/vis.log
              # ;;
            esac
          fi
            
          set +x
        '';
      };
    };

    # services.cage = {
    #   enable = true;
    #   user = "cole";
    #   program = visualizer;
    # };
  };
}
