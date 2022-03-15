{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  #_firefox = firefoxFlake.firefox-nightly-bin;
  _firefox = pkgs.firefox-wayland;
  _chromey = pkgs.ungoogled-chromium;

  ppkgs = if pkgs.system == "x86_64-linux" then [ pkgs.tribler ] else [ ];
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    ../mixins/alacritty.nix
    ../mixins/chromecast.nix
    ../mixins/fonts.nix
    ../mixins/mpv.nix
    ../mixins/pipewire.nix
    ../mixins/spotify.nix
    ../mixins/wezterm.nix
  ];

  config = {
    #nixpkgs.config.allowUnfree = true;
    hardware.opengl.enable = true;

    # TODO: light or brightnessctl? why both?
    # do we even need either or use DM?
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
        MOZ_USE_XINPUT2 = "1";
      };

      home.packages = ppkgs ++ (with pkgs; [
        colePackages.customGuiCommands

        # gui cli
        brightnessctl
        pulsemixer

        # misc gui
        evince
        gimp
        qemu
        freerdp
        vlc

        virt-viewer

        librewolf
        _firefox
        _chromey
      ]);
    };
  };
}
