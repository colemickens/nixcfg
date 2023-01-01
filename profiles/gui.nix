{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox-nightly.packages.${pkgs.hostPlatform.system};
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
    hardware.drivers.enable = true;

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
        TERMINAL = "nu";
        MOZ_USE_XINPUT2 = "1";
      };

      services = {
        pass-secret-service = {
          enable = true;
        };
      };

      home.packages = lib.mkMerge [
        (lib.mkIf (pkgs.hostPlatform.system == "x86_64-linux") (with pkgs; [
          _firefox
          _chrome
          captive-browser
        ]))
        (with pkgs; [
          (pkgs.callPackage ../pkgs/commands-gui.nix { })

          # misc tools/utils
          pavucontrol
          brightnessctl
          virt-viewer
          evince
          pinta

          pw-viz
          qpwgraph
          helvum
          jamesdsp

          # libnotify # does an app need this? patch it instead?
          # TODO: BROKEN WITH WAYLAND:?
          # qpwgraph
          # pw-viz
          # ladybird

          # communcation
          nheko
          ripcord
          freerdp
        ])
      ];
    };
  };
}
