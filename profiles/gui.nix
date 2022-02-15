{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};

  __firefoxStable = pkgs.firefox;
  __firefoxNightly = firefoxFlake.firefox-nightly-bin;

  #_someFirefox = __firefoxStable;
  _someFirefox = pkgs.firefox-wayland;
    # if pkgs.system == "x86_64-linux"
    # #then __firefoxNightly
    # then pkgs.firef
    # else pkgs.firefox-beta-bin;

  #_someChromium = pkgs.ungoogled-chromium;
  _someChromium = pkgs.google-chrome-dev;
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    #../mixins/alacritty.nix
    ../mixins/chromecast.nix
    ../mixins/fonts.nix
    ../mixins/foot.nix
    # gtk is moved to sway/gnome, we don't want it on plasma
    #../mixins/kitty.nix
    ../mixins/mpv.nix
    ../mixins/pipewire.nix
    ../mixins/qt.nix
    ../mixins/spotify.nix
    #../mixins/wezterm.nix
  # ] ++ (if pkgs.system != "x86_64-linux" then [] else [
  #   ../mixins/alacritty.nix
  # ]);
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
        MOZ_ENABLE_WAYLAND = 1;
        MOZ_USE_XINPUT2 = "1";
      };

      home.packages = with pkgs; [
        colePackages.customGuiCommands

        # gui cli
        brightnessctl
        pulsemixer
        #alsaTools
        alsaUtils

        # misc gui
        evince
        gimp
        qemu
        freerdp
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

        # browsers
        _someFirefox
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [


        _someChromium # some clang shit marked as broken on aarch64
        #thunderbird # just a bit too painful to build on aarch64
        i2c-tools
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
