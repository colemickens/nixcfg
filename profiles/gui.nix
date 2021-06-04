{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  # firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
  #   exec "${firefoxFlake.firefox-nightly-bin}/bin/firefox"
  # '';
  firefoxStable = pkgs.writeShellScriptBin "firefox-stable" ''
     exec "${inputs.stable.legacyPackages.${pkgs.system}.firefox}/bin/firefox"
  '';
  firefoxNightly = firefoxFlake.firefox-nightly-bin;
  #firefoxStable = inputs.stable.legacyPackages.${pkgs.system}.firefox
  # (pkgs.runCommandNoCC "element"
  #   { buildInputs = with pkgs; [ makeWrapper ]; }
  #   ''
  #     ln -sf ${firefoxFlake.firefox-nightly-bin}/bin/firefox $out/bin/firefox-nightly
  #     ln -sf ${firefoxFlake.firefox-nightly-bin}/share $out/share
  #   ''
  # )

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
        #vlc
        imv

        # misc utils for desktop
        brightnessctl
        pulsemixer

        # terminals
        #alacritty
        #cool-retro-term
        kitty

        # matrix clients
        fractal
        nheko
        quaternion
        spectral
        #mirage-im
        cchat-gtk
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
        firefoxStable
        firefoxNightly

        ddccontrol i2c-tools
        scrcpy
        mplayer

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
