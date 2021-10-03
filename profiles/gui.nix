{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};

  #_someFirefox = firefoxFlake.firefox-nightly-bin;
  #_someFirefox = pkgs.firefox-bin;
  _someFirefox = pkgs.firefox;
  _someChromium = pkgs.ungoogled-chromium;
  #_someFirefox = inputs.nixos-unstable.legacyPackages.${pkgs.system}.firefox;
  #_someChromium = inputs.nixos-unstable.legacyPackages.${pkgs.system}.ungoogled-chromium;

  _torPackages =
    if pkgs.system == "aarch64-linux"
    #then [ inputs.nixos-unstable.legacyPackages.${pkgs.system}.tor-browser-bundle-ports-bin ]
    then [ ]
    #else [ inputs.nixos-unstable.legacyPackages.${pkgs.system}.tor-browser-bundle-bin ];
    else [ pkgs.tor-browser-bundle-bin ];
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    ../mixins/alacritty.nix
    ../mixins/chromecast.nix
    ../mixins/fonts.nix
    ../mixins/foot.nix
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
        smplayer
        rkvm
        spotify-qt
        vlc
        # nvui # https://github.com/NixOS/nixpkgs/issues/136229

        virt-viewer
        spice-gtk

        # tribler # broken

        # matrix clients
        # fractal
        # nheko
        # quaternion
        # spectral
        # mirage-im
        # cchat-gtk
        # neochat
        # element-desktop

        gnome3.nautilus
        gnome3.file-roller
        gnome3.gnome-tweaks

        easyeffects

        # browsers
        _someChromium
        _someFirefox
        #falkon
      ]
      ++ _torPackages
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        mplayer # weird non-aarch64

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
