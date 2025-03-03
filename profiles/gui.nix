{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  firefoxFlake = inputs.firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system};
  _firefoxNightly = firefoxFlake.firefox-nightly-bin;

  # _chrome = pkgs.ungoogled-chromium;

  # we need stable chrome for work:
  # _chrome = pkgs.google-chrome-dev.override {
  #   commandLineArgs = [ "--force-dark-mode" ];
  # };
  _chrome = pkgs.google-chrome.override { commandLineArgs = [ "--force-dark-mode" ]; };
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)
    ./commands-gui.nix

    ../mixins/hw-logitech-mice.nix
    ../mixins/hw-steelseries-aerox3.nix

    # ../mixins/alacritty.nix
    ../mixins/fonts.nix
    ../mixins/ghostty.nix
    ../mixins/mpv.nix
    # ../mixins/pam-u2f.nix # separate out briefly
    ../mixins/pipewire.nix
    # ../mixins/rio.nix
    # ../mixins/wezterm.nix
  ];

  config = {
    # hm, not sure about new name, does it convery that GUI is enabled with it?
    # hardware.drivers.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    environment.variables = {
      # better fonts:
      # https://web.archive.org/web/20230921201835/https://old.reddit.com/r/linux_gaming/comments/16lwgnj/is_it_possible_to_improve_font_rendering_on_linux/
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    };

    programs.noisetorch.enable = true;

    # TODO: REMOVE SOON(?)
    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];

    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        home.sessionVariables = {
          BROWSER = "firefox";
        };

        services = {
          pass-secret-service = {
            enable = true;
            # verbose = true;
            # copied from profiles/interactive -> PASSWORD_STORE_DIR
            storePath = "${hm.config.xdg.dataHome}/password-store";
          };
          gpg-agent.pinentryBinary = "${pkgs.wayprompt}/bin/pinentry-wayprompt";
        };

        home.packages = lib.mkMerge [
          (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") (
            with pkgs;
            [
              # browsers
              _firefoxNightly
              pkgs.firefox-bin
              _chrome

              # audio/video
              jamesdsp

              # communication
              # libolm fallout:
              nheko
              # libsForQt5.kdeGear.neochat
              # libsForQt5.kdeGear.falkon

              # misc tools/utils
              # wine-wayland # oof TODO: nixpkgs wine packages need some ... attention
            ]
          ))
          (with pkgs; [
            # misc tools/utils
            brightnessctl
            evince
            freerdp
            pinta
            krita
            pinta
            virt-viewer

            dissent
            ksnip

            glide-media-player

            # broken, again:
            # mission-center

            zed-editor

            vokoscreen-ng
            wayfarer

            # audio/video
            pwvucontrol
            pw-viz # also failing to build again
            qpwgraph
            helvum

            # communication
            # thunderbird
            linphone
          ])
        ];
      };
  };
}
