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
    ../mixins/mpv.nix
    ../mixins/pipewire.nix
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
          verbose = true;
          # copied from profiles/interactive -> PASSWORD_STORE_DIR
          storePath = "${hm.config.xdg.dataHome}/password-store";
        };
      };

      home.packages = lib.mkMerge [
        (lib.mkIf (pkgs.hostPlatform.system == "x86_64-linux") (with pkgs; [
          _firefox
          _chrome
          captive-browser
          jamesdsp

          nheko
        ]))
        (with pkgs; [
          (pkgs.callPackage ../pkgs/commands-gui.nix { })

          # misc tools/utils
          pavucontrol
          brightnessctl
          virt-viewer
          evince
          pinta

          gtkcord4

          pw-viz
          qpwgraph
          # helvum

          # libnotify # `notify-send`
          toastify
          # TODO: BROKEN WITH WAYLAND:?
          # qpwgraph
          # ladybird # qt? long build anyway?

          # communcation
          freerdp
        ])
      ];
    };
  };
}
