{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${firefoxFlake.firefox-nightly-bin}/bin/firefox "''${@}"
  '';
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
    #../mixins/obs.nix
    ../mixins/qt.nix
    ../mixins/termite.nix
  ];
  # TODO: xdg-user-dirs fixup

  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays =  [
      inputs.wayland.overlay
    ];

    hardware = {
      opengl = {
        enable = true;
        extraPackages = []
        ++ lib.optionals (pkgs.system=="x86_64-linux") (with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ]);
        driSupport32Bit = (pkgs.system=="x86_64-linux");
      };
      pulseaudio.enable = true;
    };
    nixpkgs.config.pulseaudio = true;
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = true;
      };
    };

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
        freerdp
        wlvncc
        vlc

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

        # browsers
        firefox
        chromium
        #firefox-bin
        #torbrowser
        #falkon
        #nyxt

        # yucky non-free
        #discord
        gtkcord3
        #ripcord
        #spotify

        # games
        #inputs.nixos-veloren.packages.${pkgs.system}.veloren
      ]
      ++ builtins.attrValues pkgs.customGuiCommands # include custom overlay gui pkgs
      ++ lib.optionals (pkgs.system == "x86_64-linux") [
        pkgs.vscodium
        firefoxNightly
        pkgs.chromium
        pkgs.torbrowser
        pkgs.falkon

        # yucky non-free
        pkgs.discord
        pkgs.ripcord
        pkgs.spotify
      ];
    };
  };
}
