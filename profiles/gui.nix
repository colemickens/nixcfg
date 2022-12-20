{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox-nightly.packages.${pkgs.hostPlatform.system};
  # _firefox = pkgs.firefox-wayland;
  _firefox = lib.hiPrio firefoxFlake.firefox-nightly-bin;

  # _chrome = pkgs.ungoogled-chromium;
  _chrome = pkgs.google-chrome-dev.override {
    commandLineArgs = [ "--force-dark-mode" ];
  };

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
    hardware.drivers.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    # TODO: light or brightnessctl? why both?
    # do we even need either or use DM?
    programs.light.enable = true;

    home-manager.users.cole = { pkgs, config, ... }@hm: {
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
        NIXOS_OZONE_WL = "1";
      };

      services = {
        pass-secret-service = {
          enable = true;
        };
        # syncthing = {
        #   tray.enable = hm.config.services.syncthing.enable;
        # };
      };

      home.packages = (
        (with pkgs; [
          (pkgs.callPackage ../pkgs/commands-gui.nix { })

          # misc tools/utils
          brightnessctl
          virt-viewer
          # qpwgraph # why doesn't this default to working with wayland?
          libnotify
          evince
          pinta
          # gimp # lol wayland support when
          # freerdp
          # vlc

          # communcation
          twinkle
          linphone
          nheko
          ripcord
          freerdp

          # browsers
          ladybird
        ]) ++ (lib.optionals (pkgs.hostPlatform.system == "x86_64-linux") (with pkgs; [
          # x86_64-linux only

          # browsers
          _firefox
          _chrome
          captive-browser
        ]))
      );
    };
  };
}
