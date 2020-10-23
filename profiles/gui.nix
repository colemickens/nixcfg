{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${firefoxFlake.firefox-nightly-bin}/bin/firefox "''${@}"
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
    ../mixins/qt.nix
    ../mixins/spotify.nix
    ../mixins/termite.nix
  ];
  # TODO: xdg-user-dirs fixup

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays =  [
      inputs.nixpkgs-wayland.overlay
    ];

    hardware.opengl.enable = true;
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;

    services.pcscd.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        BROWSER = "firefox";
        TERMINAL = "termite";
      };
      services = {
        udiskie.enable = true;
      };
      home.packages = with pkgs; [
        # misc
        evince
        gimp
        qemu
        vscodium
        #vscode
        freerdp
        wlvncc
        virt-viewer
        #vlc

        # misc utils for desktop
        brightnessctl
        pulsemixer

        # terminals
        alacritty
        cool-retro-term
        kitty
        termite

        # matrix clients
        fractal
        #nheko
        quaternion
        spectral
        mirage-im
        element-desktop
        cchat-gtk

        # browsers
        firefox
        #chromium
        falkon
        #torbrowserPkg
      ]
      ++ builtins.attrValues pkgs.customGuiCommands # include custom overlay gui pkgs
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        firefoxNightly # pre-built, Moz doesn't seem to build nightly aarch64?
        scrcpy

        # yucky non-free
        pkgs.google-chrome-dev
        pkgs.discord
        pkgs.ripcord
        pkgs.spotify
      ];
    };
  };
}
