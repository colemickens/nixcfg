{ pkgs, config, ... }:

let
  findImport = (import ../../../lib.nix).findImport;
  home-manager = findImport "extras" "home-manager";

  termiteFont = "Noto Sans Mono 11";

  chromium-dev-ozone = import (findImport "extras" "nixpkgs-chromium");

  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${pkgs.latest.firefox-nightly-bin}/bin/firefox "''${@}"
  '';
in
{
  imports = [
    ./interactive.nix
    ./config/fonts.nix
    "${home-manager}/nixos"
  ];

  # TODO: xdg-user-dirs fixup

  config = {
    # <nixpkgs + overlays>
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays =  [
      (import (findImport "overlays" "nixpkgs-mozilla"))
      (import (findImport "overlays" "nixpkgs-wayland"))
    ];
    # </nixpkgs + overlays>

    # <gfx+audio>
    hardware = {
      # TODO: move to separate opengl-y module?
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
    # </gfx+audio>

    services.pipewire.enable = true;
    programs.sway.enable = true; # needed for swaylock/pam stuff
    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;
    xdg.portal.extraPortals = with pkgs;
      [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";
        SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
        WLR_DRM_NO_MODIFIERS = "1";
        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
      };
      # TODO: can't enable without weird error
      #fonts.fontconfig.enable = true;
      gtk = {
        enable = true;
        #font = { name = "Noto Sans 11"; package = pkgs.noto-fonts; };
        #iconTheme = { name = "Numix"; package = pkgs.numix-icon-theme; };
        #cursorTheme = { name = "Adwaita"; package = pkgs.gnome3.adwaita-icon-theme; };
        theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
        #font = { name = "Noto Sans,10,-1,5,50,0,0,0,0,0,Regular"; package = pkgs.noto-fonts; };
        #iconTheme = { name = "Numix"; package = pkgs.numix-icon-theme; };
        #style = { name = "Breeze"; package = pkgs.breeze-qt5; };
      };
      programs = {
        alacritty = import ./config/alacritty-config.nix {};
        htop.enable = true;
        mako.enable = true;
        mpv = import ./config/mpv-config.nix;
        obs-studio = {
          enable = true;
          plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
        };
        termite = import ./config/termite-config.nix {
          font = termiteFont;
        };
      };
      services = {
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableExtraSocket = true;
        };
        redshift = import ./config/redshift-config.nix { inherit pkgs; };
        udiskie.enable = true;
      };
      wayland.windowManager.sway = import ./config/sway-config.nix {
        inherit pkgs firefoxNightly;
      };
      xdg.configFile = {
        "wayvnc/config".source = ./config/wayvnc/vnc.cfg;
      };
      home.packages = with pkgs; [
        qemu
        evince #calibre
        wlfreerdp
        gimp mpv vlc
        vscodium

        # fonts
        corefonts
        inconsolata
        font-awesome nerdfonts powerline-fonts
        noto-fonts noto-fonts-emoji
        numix-icon-theme arc-theme

        # sway
        swaybg swayidle swaylock # TODO: needed with hm module?
        xwayland i3status-rust slurp grim wf-recorder
        udiskie termite drm_info
        imv mako redshift-wayland
        wayvnc wl-clipboard wl-gammactl

        # browsers
        firefox firefoxNightly
        chromium
        #chromium-dev-ozone

        # comms
        #thunderbird
        #fractal quaternion spectral
        riot-desktop

        # virt-manager # TODO: tie to the system virt-manager enablement somehow?
        # but we don't really want it reaching into HM stuff, so maybe this is just fine
        virt-manager # TODO: make a home-manager module, clearly

        # utils/misc
        brightnessctl
        pavucontrol
        pulsemixer
        qt5.qtwayland

        # appearance
        arc-icon-theme arc-theme numix-icon-theme hicolor-icon-theme

        # <nonfree> ewwwww...
        discord ripcord slack # => matrix + bridge
        spotify
        # </nonfree>
      ] ++ lib.optionals (config.services.upower.enable)
        [
          intel-gpu-tools
        ];
    };
  };
}
