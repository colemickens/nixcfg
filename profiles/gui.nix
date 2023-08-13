{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system};
  # _firefox = pkgs.firefox-wayland;
  _firefox = lib.hiPrio firefoxFlake.firefox-nightly-bin;

  # _chrome = pkgs.ungoogled-chromium;
  _chrome = pkgs.google-chrome-dev.override {
    commandLineArgs = [ "--force-dark-mode" ];
  };

in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    ../mixins/hw-logitech-mice.nix
    ../mixins/hw-steelseries-aerox3.nix

    ../mixins/alacritty.nix
    ../mixins/fonts.nix
    ../mixins/gtk.nix
    ../mixins/kitty.nix
    ../mixins/mpv.nix
    ../mixins/pipewire.nix
    ../mixins/rio.nix
    ../mixins/wezterm.nix
  ];

  config = {
    # hm, not sure about new name, does it convery that GUI is enabled with it?
    # hardware.drivers.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    programs.noisetorch.enable = true;

    services = { };

    home-manager.users.cole = { pkgs, config, ... }@hm: {
      # home-manager/#2064
      systemd.user.targets.tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
      };

      home.sessionVariables = {
        BROWSER = "firefox";
        # TERMINAL = "nu";
        # MOZ_USE_XINPUT2 = "1";
      };

      services = {
        pass-secret-service = {
          enable = true;
          # verbose = true;
          # copied from profiles/interactive -> PASSWORD_STORE_DIR
          storePath = "${hm.config.xdg.dataHome}/password-store";
        };
        gpg-agent.pinentryBinary =
          let
            wayprompt = "${inputs.nixpkgs-wayland.outputs.packages.${pkgs.stdenv.hostPlatform.system}.wayprompt}";
          in
          "${wayprompt}/bin/pinentry-wayprompt";
        # gpg-agent.pinentryBinary = "${pkgs.pinentry-qt}/bin/pinentry";
      };

      home.packages = lib.mkMerge [
        (lib.mkIf (pkgs.hostPlatform.system == "x86_64-linux") (with pkgs; [
          _firefox
          _chrome
          jamesdsp

          nheko
          wine
        ]))
        (with pkgs; [
          (pkgs.callPackage ../pkgs/commands-gui.nix { })

          # misc tools/utils
          brightnessctl
          pavucontrol
          evince
          freerdp
          pinta
          pw-viz
          qpwgraph
          toastify
          virt-viewer

          thunderbird

          # questionable...
          gtkcord4

        ])
      ];
    };
  };
}
