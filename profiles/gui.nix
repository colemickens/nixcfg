{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};

  __firefoxStable = pkgs.firefox;
  __firefoxNightly = firefoxFlake.firefox-nightly-bin;
  
  #_someFirefox = __firefoxStable;
  _someFirefox =
    if pkgs.system == "x86_64-linux"
    then __firefoxNightly
    else pkgs.firefox-beta-bin;

  #_someChromium = pkgs.ungoogled-chromium;
  _someChromium = pkgs.google-chrome-dev;
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
        TERMINAL = "foot";
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
        meld
        #vscodium
        freerdp
        # remmina # webkitgtk
        imv
        smplayer
        rkvm
        spotify-qt
        spot
        vlc
        wezterm
        celluloid
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

        #gnome3.gnome-tweaks # webkitgtk
        # gnome3.nautilus # yikes tracker-miner->evolution-data-server->webkit-gtk
        # gnome3.file-roller # lmao same

        # browsers
        _someFirefox
        #falkon
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        # on aarch64, calibre fails:
        # │ERROR: PyQt5-5.15.4-cp36-abi3-manylinux1_aarch64.whl is not a supported wheel on this platform.                                              │
        # │error: builder for '/nix/store/6gn43c11crvvgw179sbsn8v1jp2v78gd-python3.9-PyQt5-5.15.4.drv' failed with exit code 1;                         │
        # │       last 10 log lines:                                                                                                                    │
        # │       >   Stored in directory: /build/pip-ephem-wheel-cache-d0ote7rr/wheels/cd/3f/5d/9435146fd48488b53ec1d4536e6c05cb66253e156fca019124     │
        # │       > Successfully built PyQt5                                                                                                            │
        # │       > Finished creating a wheel...                                                                                                        │
        # │       > Finished executing pipBuildPhase                                                                                                    │
        # │       > glibPreInstallPhase                                                                                                                 │
        # │       > glibPreInstallPhase                                                                                                                 │
        # │       > installing                                                                                                                          │
        # │       > Executing pipInstallPhase                                                                                                           │
        # │       > /build/PyQt5-5.15.4/dist /build/PyQt5-5.15.4                                                                                        │
        # │       > ERROR: PyQt5-5.15.4-cp36-abi3-manylinux1_aarch64.whl is not a supported wheel on this platform.                                     │
        # │       For full logs, run 'nix log /nix/store/6gn43c11crvvgw179sbsn8v1jp2v78gd-python3.9-PyQt5-5.15.4.drv'. 
        calibre


        _someChromium # some clang shit marked as broken on aarch64
        #thunderbird # just a bit too painful to build on aarch64
        ddccontrol
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
