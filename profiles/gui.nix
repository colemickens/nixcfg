{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec "${firefoxFlake.firefox-nightly-bin}/bin/firefox"
  '';
  firefoxStable = pkgs.writeShellScriptBin "firefox-stable" ''
     exec "${inputs.nixos-unstable.legacyPackages.${pkgs.system}.firefox}/bin/firefox"
  '';
  _firefoxBin = pkgs.writeShellScriptBin "firefox-bin" ''
     exec "${inputs.nixos-unstable.legacyPackages.${pkgs.system}.firefox-bin}/bin/firefox"
  '';
  firefoxBin = pkgs.writeShellScriptBin "firefox-bin" ''
     exec "${pkgs.firefox-bin}/bin/firefox"
  '';

  torbrowserPkg =
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
    #../mixins/termite.nix
  ];
  # TODO: xdg-user-dirs fixup

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
        TERMINAL = "termite";
        MOZ_USE_XINPUT2 = "1";
      };
      services = {
        udiskie.enable = true;
      };
      home.packages = with pkgs; [
        colePackages.customGuiCommands
        glxinfo

        # misc
        evince
        gimp
        qemu
        # (pkgs.writeScriptBin "codium" ''
        #   ${pkgs.vscodium}/bin/codium  --enable-features=UseOzonePlatform --ozone-platform=wayland "''${@}"
        # '')
        (pkgs.runCommandNoCC "codium"
          { buildInputs = with pkgs; [ makeWrapper ]; }
          ''
            makeWrapper ${pkgs.vscodium}/bin/codium $out/bin/codium \
              --add-flags "--enable-features=UseOzonePlatform" \
              --add-flags "--ozone-platform=wayland"

            ln -sf ${pkgs.vscodium}/share $out/share
          ''
        )
        #vscode
        freerdp
        virt-viewer
        remmina
        #vlc
        imv

        thunderbird

        # misc utils for desktop
        brightnessctl
        pulsemixer

        meld

        # terminals
        kitty

        # matrix clients
        fractal
        nheko
        quaternion
        spectral
        #mirage-im
        #cchat-gtk
        neochat
        #element-desktop
        (pkgs.runCommandNoCC "element"
          { buildInputs = with pkgs; [ makeWrapper ]; }
          ''
            makeWrapper ${pkgs.element-desktop}/bin/element-desktop $out/bin/element-desktop \
              --add-flags "--enable-features=UseOzonePlatform" \
              --add-flags "--ozone-platform=wayland"

            ln -sf ${pkgs.element-desktop}/share $out/share
          ''
        )

        rkvm
        spotify-qt

        gnome3.nautilus
        gnome3.file-roller
        gnome3.gnome-tweaks
        spice-gtk
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        # browsers
        #(let
        #  c = inputs.nixos-unstable.legacyPackages.${pkgs.system}.ungoogled-chromium;
        #  #c = pkgs.ungoogled-chromium;
        #in pkgs.runCommandNoCC "wrap-chromium"
        #  { buildInputs = with pkgs; [ makeWrapper ]; }
        #  ''
        #    makeWrapper ${c}/bin/chromium $out/bin/chromium \
        #      --add-flags "--enable-features=UseOzonePlatform" \
        #      --add-flags "--ozone-platform=wayland"

        #    ln -sf ${c}/share $out/share
        #  ''
        #)
        #inputs.stable.legacyPackages.${pkgs.system}.ungoogled-chromium
        inputs.stable.legacyPackages.${pkgs.system}.torbrowser
        #firefoxStable
        #firefoxBin
        #firefoxNightly
        pkgs.firefox-bin

        ddccontrol i2c-tools
        scrcpy
        mplayer
        smplayer
        alsaTools
        alsaUtils

        syncthing-gtk

        # yucky non-free
        discord
        ripcord

        # not supported on aarch64, likely its an appimage or something
        radicle-upstream
      ] ++ lib.optionals (pkgs.system == "aarch64-linux") [
        # use stable on aarch64-linux
        inputs.stable.legacyPackages.${pkgs.system}.firefox
        #inputs.stable.legacyPackages.${pkgs.system}.ungoogled-chromium
      ];
    };
  };
}
