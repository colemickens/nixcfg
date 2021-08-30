{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};

  #_someFirefox = firefoxFlake.firefox-nightly-bin;
  #_someFirefox = pkgs.firefox-bin;
  _someFirefox = pkgs.firefox;
  _someChromium = pkgs.ungoogled-chromium;

  _torPackage =
    if pkgs.system == "aarch64-linux"
    then pkgs.tor-browser-bundle-ports-bin
    else pkgs.tor-browser-bundle-bin;
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    ../mixins/alacritty.nix
    ../mixins/chromecast.nix
    ../mixins/fonts.nix
    ../mixins/gtk.nix
    ../mixins/kitty.nix
    ../mixins/mpv.nix
    ../mixins/mako.nix
    ../mixins/pipewire.nix
    ../mixins/qt.nix
    ../mixins/spotify.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;

    hardware.opengl.enable = true;
    # see pipewire.nix for pulseaudio/pipewire stuffs

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
        TERMINAL = "alacritty";
        MOZ_USE_XINPUT2 = "1";
      };
      services = {
        udiskie.enable = true;
      };
      home.packages = with pkgs; [
        colePackages.customGuiCommands

        # gui cli
        brightnessctl
        pulsemixer
        alsaTools
        alsaUtils

        # misc gui
        glxinfo
        evince
        gimp
        qemu
        meld
        vscodium
        freerdp
        remmina
        imv
        syncthing-gtk
        thunderbird
        mplayer
        smplayer
        rkvm
        spotify-qt
        nvui

        virt-viewer
        spice-gtk

        # matrix clients
        fractal
        nheko
        quaternion
        spectral
        mirage-im
        cchat-gtk
        neochat
        element-desktop

        gnome3.nautilus
        gnome3.file-roller
        gnome3.gnome-tweaks

        # browsers
        _someChromium
        _torPackage
        _someFirefox
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        ddccontrol
        i2c-tools

        # yucky non-free
        discord
        ripcord

        # android
        scrcpy

        # not supported on aarch64, likely its an appimage or something
        radicle-upstream
      ] ++ lib.optionals (pkgs.system == "aarch64-linux") [
        # not sure ?
      ];
    };
  };
}
