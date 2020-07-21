{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firenight.packages.${pkgs.system};
  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${firefoxFlake.firefox-nightly-bin}/bin/firefox "''${@}"
  '';
  firefoxPipewire = pkgs.writeShellScriptBin "firefox-pipewire" ''
    exec ${firefoxFlake.firefox-pipewire}/bin/firefox "''${@}"
  '';

  extraPkgs = [
    firefoxNightly
    #firefoxPipewire
    #inputs.chromium.chromium-ozone-dev
  ];
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
    ../mixins/obs.nix
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
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
        ];
        driSupport32Bit = true;
      };
      pulseaudio.enable = true;
    };
    nixpkgs.config.pulseaudio = true;
    nixpkgs.config.packageOverrides = pkgs: {  
      vaapiIntel = pkgs.vaapiIntel.override {
        enableHybridCodec = true;
      };
    };

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
        imv
        qemu
        vscodium
        
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
        nheko
        quaternion
        spectral
        mirage-im
        
        # browsers
        firefox-bin
        chromium
        torbrowser
        falkon
        #nyxt

        # yucky non-free
        discord
        spotify
      ]
      ++ builtins.attrValues pkgs.customGuiCommands # include custom overlay gui pkgs
      ++ extraPkgs; # include custom pkgs from this file (firefoxNightly with flakes)
    };
  };
}
