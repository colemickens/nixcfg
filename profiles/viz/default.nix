{ pkgs, lib, config, inputs, ... }:

let
  useUnstableOverlay = true;
in
{
  imports = [
    # ../../profiles/user.nix
    ../../secrets
    ../../mixins/common.nix

    ../../mixins/pipewire.nix # snapcast
    ../../mixins/snapclient-local.nix # snapcast
    ../../mixins/tailscale.nix
    ../../mixins/sshd.nix
  ];
  config = {
    sops.secrets."tailscale-join-authkey".owner = "cole";
    
    nixpkgs.overlays =
      if useUnstableOverlay then [
        inputs.nixpkgs-wayland.overlay
      ] else [ ];

    services.getty.autologinUser = "cole";

    environment.systemPackages = with pkgs; [
      # mpv
      v4l-utils
      wezterm
      foot
      gst_all_1.gstreamer
      gst_all_1.gstreamer.dev
      qt5.qtwayland
    ];
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    environment.etc."sway/config".source = ./viz-sway-config;

    environment.loginShellInit = ''
      # [[ "$(tty)" == /dev/tty? ]] && sudo /run/current-system/sw/bin/lock this 
      [[ "$(tty)" == /dev/tty1 ]] && sway
    '';

    systemd.user.services.visualizer = {
      enable = true;
      description = "Visualizer";

      wantedBy = [ "multi-user.target" ];
      partOf = [ "graphical-session.target" ];

      environment = {
        WAYLAND_DISPLAY="wayland-1";
      };
      script = ''
        "${pkgs.foot}/bin/foot" "${pkgs.cli-visualizer}/bin/vis"
      '';
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
