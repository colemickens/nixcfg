{ pkgs, lib, config, inputs, ... }:

# NOTES:
# - seems like on rpi3, audio will work if video starts first
#   so one change here is to have audio restart after video
let
  useUnstableOverlay = true;
  __scripts = pkgs.buildEnv {
    name = "viz-scripts";
    paths = [
      (pkgs.writeShellScriptBin "viz-restart-pipewire" ''
        set -x
        systemctl --user stop pipewire pipewire-pulse pipewire.socket pipewire-pulse.socket
        sleep 2
        systemctl --user start pipewire.socket pipewire-pulse.socket pipewire.service pipewire-pulse.service
        sleep 2
        if [[ "$(hostname)" == "rpithreebp1" ]]; then sleep 10; fi
        systemctl --user restart snapclient-local
      '')
      (pkgs.writeShellScriptBin "viz-restart-visualizer" ''
        systemctl --user restart visualizer
      '')
      (pkgs.writeShellScriptBin "viz-sway-autorun" ''
        /run/current-system/sw/bin/viz-restart-pipewire
        sleep 2
        /run/current-system/sw/bin/viz-restart-visualizer
      '')
    ];
  };

  # useVulkan = (config.networking.hostName == "rpifour2");
  useVulkan = false;

  vs_pm = ''"${pkgs.projectm}/bin/projectM-pulseaudio"'';
  vs_vis = ''"${pkgs.foot}/bin/foot" "${pkgs.cli-visualizer}/bin/vis"'';
  visualizerScript = (
    (rec {
      # "rpifour1" = vs_pm;
      # "rpifour2" = vs_pm;
      "rpifour1" = vs_vis;
      "rpithreebp1" = vs_vis;

      "rpizerotwo1" = vs_vis;
      "rpizerotwo2" = vs_vis;
      "radxazero1" = vs_vis;
      "rockfiveb1" = vs_vis;
    }).${config.networking.hostName}
  );

  isCross = pkgs.targetPlatform != pkgs.buildPlatform;
in
{
  imports = [
    # ../../profiles/user-cole.nix
    ../secrets
    ../mixins/common.nix

    ../mixins/pipewire.nix # snapcast
    ../mixins/snapclient-local.nix # snapcast
    ../mixins/tailscale.nix
    ../mixins/sshd.nix
  ];
  config = {
    sops.secrets."tailscale-join-authkey".owner = "cole";

    nixpkgs.overlays =
      if useUnstableOverlay then [
        inputs.nixpkgs-wayland.overlay
      ] else [ ];

    services.getty.autologinUser = "cole";

    environment.systemPackages = (with pkgs; ([
      wezterm
      foot
      gst_all_1.gstreamer
      gst_all_1.gstreamer.dev
      qt5.qtwayland
      __scripts
      cava
      cli-visualizer
    ] ++ (if isCross then [ ] else [
      # these don't cross-compile due to makeWrapper issues?
      alsa-utils
      v4l-utils
      mpv
    ])));
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = (''
        export WLR_LIBINPUT_NO_DEVICES=1
      '' + (lib.optionalString (useVulkan) ''
        export WLR_RENDERER=vulkan
      ''));
    };
    environment.etc."sway/config".text = ''
    '';

    environment.loginShellInit = ''
      # [[ "$(tty)" == /dev/tty? ]] && sudo /run/current-system/sw/bin/lock this 
      [[ "$(tty)" == /dev/tty1 ]] && (
        sleep 2;
        sway -d &> sway.log
      )
    '';

    systemd.user.services.visualizer = {
      enable = true;
      description = "Visualizer";

      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        QT_QPA_PLATFORM = "wayland-egl";
      };
      script = visualizerScript;
      restartIfChanged = true;
      serviceConfig = {
        # ExecStart
        Restart = "always";
        RestartSec = 3;
        # Install = { WantedBy = [ "sway-session.target" ]; };
      };
    };
  };
}
