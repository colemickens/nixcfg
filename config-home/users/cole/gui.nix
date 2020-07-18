{ pkgs, lib, config, inputs, ... }:

let
  firefoxFlake = inputs.firenight.packages.${pkgs.system};
  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${firefoxFlake.firefox-nightly-bin}/bin/firefox "''${@}"
  '';
  firefoxPipewire = pkgs.writeShellScriptBin "firefox-pipewire" ''
    exec ${firefoxFlake.firefox-pipewire}/bin/firefox "''${@}"
  '';

  browser_nightly = "${firefoxNightly}/bin/firefox-nightly -P nightly-default";
  browser_firefox = "${pkgs.firefox-bin}/bin/firefox -P stable-default";
  terminal_termite = "${pkgs.termite}/bin/termite";
  terminal_alacritty = "${pkgs.alacritty}/bin/alacritty";
  terminal_kitty = "${pkgs.kitty}/bin/kitty";
  terminal_wezterm = "${pkgs.wezterm}/bin/wezterm";

  browser = browser_firefox;
  terminal = terminal_termite;

  #chromium-ozone-dev = chromiumFlake.chromium-ozone-dev;
  extraPkgs = [
    firefoxNightly
    #firefoxPipewire
    #chromium-ozone-dev
  ];
in
{
  imports = [
    ./interactive.nix # includes core.nix (which imports hm)
    ./config/fonts.nix
  ];

  # TODO: xdg-user-dirs fixup

  config = {
    # <nixpkgs + overlays>
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays =  [
      inputs.wayland.overlay
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
    programs.sway.extraPackages = []; # block rxvt
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
        BROWSER = browser;
        TERMINAL = terminal;
      };
      gtk = import ./config/gtk-config.nix { inherit pkgs; };
      qt = { enable = true; platformTheme = "gtk"; };
      programs = {
        alacritty = import ./config/alacritty-config.nix { inherit pkgs; };
        htop.enable = true;
        kitty = import ./config/kitty-config.nix { inherit pkgs; };
        mako.enable = true;
        mpv = import ./config/mpv-config.nix;
        obs-studio = {
          enable = true;
          plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
        };
        termite = import ./config/termite-config.nix { inherit pkgs; };
        waybar = import ./config/waybar-config.nix { inherit pkgs; };
      };
      services = {
        gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableExtraSocket = true;
          defaultCacheTtl = 34560000;
          defaultCacheTtlSsh = 34560000;
        };
        redshift = import ./config/redshift-config.nix { inherit pkgs; };
        udiskie.enable = true;
      };
      wayland.windowManager.sway = import ./config/sway-config.nix {
        inherit pkgs browser terminal;
      };
      xdg.configFile = {
        "wayvnc/config".source = ./config/wayvnc/vnc.cfg;
      };
      home.packages = with pkgs; [
        # misc
        asciinema
        qemu
        gimp imv evince #vlc
        wlfreerdp
        vscodium # TODO: maybe home-manager-ize?
        #vscode
        cool-retro-term
        brightnessctl
        pulsemixer
        virt-manager # TODO: usb passthrough needs something else?
        #nyxt

        fractal
        nheko
        quaternion
        spectral
        mirage-im

        # sway-related
        xwayland slurp grim wf-recorder
        wdisplays
        udiskie drm_info
        wayvnc wl-clipboard wl-gammactl
        wev

        # browsers
        chromium
        torbrowser
        falkon

        # environmental? (TODO: a module should maybe do this?)
        qt5.qtwayland

        discord spotify # nonfree ewwwww...
      ]
      ++ builtins.attrValues customGuiCommands # include custom overlay gui pkgs
      ++ extraPkgs; # include custom pkgs from this file (firefoxNightly with flakes)
    };
  };
}
