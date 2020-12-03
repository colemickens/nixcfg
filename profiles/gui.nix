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
        colePackages.customGuiCommands # from overlay

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
        #termite

        # matrix clients
        fractal
        #nheko
        quaternion
        spectral
        mirage-im
        element-desktop
        cchat-gtk

        gnome3.nautilus
        gnome3.gnome-tweaks

        #webcamoid
        #nyxt

        # browsers
        # firefox+chromium are now arch-specific
        #inputs.nixos-unstable.legacyPackages.${pkgs.system}.firefox
        #inputs.nixos-unstable.legacyPackages.${pkgs.system}.chromium
        #inputs.nixos-unstable.legacyPackages.${pkgs.system}.ungoogled-chromium
        #inputs.nixos-unstable.legacyPackages.${pkgs.system}.chromiumBeta
        #falkon
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        # use nixos-unstable on x86_64-linux
        inputs.nixos-unstable.legacyPackages.${pkgs.system}.firefox
        inputs.nixos-unstable.legacyPackages.${pkgs.system}.chromium

        scrcpy
        imv

        # yucky non-free
        discord
        pkgs.google-chrome-dev
        torbrowserPkg
        pkgs.ripcord
      ] ++ lib.optionals (pkgs.system == "aarch64-linux") [
        # use stable on aarch64-linux
        inputs.stable.legacyPackages.${pkgs.system}.firefox
        inputs.stable.legacyPackages.${pkgs.system}.chromium
      ];
    };
  };
}
