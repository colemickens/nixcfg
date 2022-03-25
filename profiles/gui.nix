{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  #_firefox = firefoxFlake.firefox-nightly-bin;
  _firefox = pkgs.firefox-wayland;
  _chromey = pkgs.ungoogled-chromium;
  _element = pkgs.element-desktop-wayland;
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
      
      services.pass-secret-service = {
        enable = true;
      };

      home.packages = (with pkgs; [
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
        vlc

        virt-viewer

        nheko
        librewolf
        _element
        _firefox
        _chromey
      ]);
    };
  };
}
