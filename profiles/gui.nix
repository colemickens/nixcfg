{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firefox.packages.${pkgs.system};
  #_firefox = firefoxFlake.firefox-nightly-bin;
  _firefox = pkgs.firefox-wayland;

  ppkgs =
    if pkgs.system == "x86_64-linux" then
      (with pkgs; [
        tribler # likely broken still on aarch64-linux
      ]) else if pkgs.system == "aarch64-linux" then
      (with pkgs; [
      ]) else
      (with pkgs; [
      ]);
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)

    ../mixins/alacritty.nix
    ../mixins/chromecast.nix
    ../mixins/fonts.nix
    #../mixins/foot.nix
    ../mixins/mpv.nix
    ../mixins/pipewire.nix
    ../mixins/qt.nix
    ../mixins/spotify.nix
    ../mixins/wezterm.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;
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
        MOZ_ENABLE_WAYLAND = 1;
        MOZ_USE_XINPUT2 = "1";
      };

      home.packages = ppkgs ++ (with pkgs; [
        colePackages.customGuiCommands

        # gui cli
        brightnessctl
        pulsemixer
        alsaUtils

        # misc gui
        evince
        gimp
        qemu
        freerdp
        spotify-qt
        vlc
        glide

        virt-viewer
        spice-gtk # why do we need this? were we trying spicy? I think virt-viewer has picked up
        # hidpi fixes, so we can ditch this probably

        _firefox
        ungoogled-chromium
      ]);
    };
  };
}
