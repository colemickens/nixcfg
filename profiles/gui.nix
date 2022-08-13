{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  # _firefox = pkgs.firefox-wayland;
  _firefox = lib.hiPrio firefoxFlake.firefox-nightly-bin;

  _chromey = pkgs.ungoogled-chromium;
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    ../mixins/alacritty.nix
    ../mixins/chromecast.nix
    ../mixins/fonts.nix
    ../mixins/mpv.nix
    ../mixins/pipewire.nix
    ../mixins/spotify.nix
    ../mixins/wezterm.nix
  ];

  config = {
    hardware.opengl.enable = true;
    hardware.opengl.extraPackages = [
      pkgs.vulkan-validation-layers
    ];

    # TODO: light or brightnessctl? why both?
    # do we even need either or use DM?
    programs.light.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      # home-manager/#2064
      systemd.user.targets.tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
      };

      home.sessionVariables = {
        BROWSER = "firefox";
        MOZ_USE_XINPUT2 = "1";
      };

      # fucking god damn python and it's fucking god damn crypto lib always breaking
      services.pass-secret-service = {
        enable = true;
      };

      home.packages = (
        (with pkgs; [
          colePackages.customGuiCommands

          # gui cli
          brightnessctl
          pulsemixer

          # misc gui
          libnotify
          evince
          gimp
          qemu
          freerdp
          # vlc
          lapce
          
          wpa_supplicant_gui
          # jami-daemon
          # jami-client-gnome

          virt-viewer

          nheko
          # librewolf
        ]) ++ (lib.optionals (pkgs.system == "x86_64-linux") (with pkgs; [
          # x86_64-linux only
          neochat
          _firefox
          # _chromey
        ]))
      );
    };
  };
}
