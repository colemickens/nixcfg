{ pkgs, config, ... }:

let
  home-manager = import ../imports/home-manager;
  overlay = (import ../lib.nix).overlay;
  pfont = "Noto Sans Mono";

  firefoxNightly = pkgs.writeShellScriptBin "firefox-nightly" ''
    exec ${pkgs.latest.firefox-nightly-bin}/bin/firefox "''${@}"
  '';
in
{
  imports = [
    "${home-manager}/nixos"
  ];

  config = {
    # <nixpkgs + overlays>
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays =  [
      (overlay "nixpkgs-mozilla")
      (overlay "nixpkgs-wayland")
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

    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;
    xdg.portal.extraPortals = with pkgs;
      [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";
        #WLR_DRM_NO_MODIFIERS = "1";
      };
      # TODO: can't enable without weird error
      # fonts.fontconfig.enable = true;
      gtk = {
        enable = true;
        #font = { name = "${pfont} 11"; package = pkgs.noto-fonts; };
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
        htop.enable = true;
        keychain = {
          enable = true;
          agents = []; # TODO?
          enableFishIntegration = true;
        };
        mako.enable = true;
        mpv = {
          enable = true;
	  config = {
	    hwdec = "vaapi";
	    vo = "gpu";
	    hwdec-codecs = "all";
	    gpu-context = "wayland";
	  };
        };
        obs-studio = {
          enable = true;
          plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
        };
        termite = {
          enable = true;
	  font = "monospace 13";
          backgroundColor = "#000000";
          cursorColor = "#ffffff";
          foregroundColor = "#babdb6";
          foregroundBoldColor = "#babdb6";
          colorsExtra = ''
            color0  = #2e3436
            color8  = #555753
            color1  = #cc0000
            color9  = #ef2929
            color2  = #4e9a06
            color10 = #8ae234
            color3  = #c4a000
            color11 = #fce94f
            color4  = #3465a4
            color12 = #729fcf
            color5  = #75507b
            color13 = #ad7fa8
            color6  = #06989a
            color14 = #34e2e2
            color7  = #d3d7cf
            color15 = #eeeeec
          '';
        };
      };
      services = {
        redshift = {
          enable = true;
          longitude = "-122.3321";
          latitude = "47.6062";
          #temperature.day = "6500K";
          #temperature.night = "4000K";
          temperature.day = 6500;
          temperature.night = 4000;
          package = pkgs.redshift-wayland;
        };
        udiskie.enable = true;
      };
      wayland.windowManager.sway = {
        enable = true;
	config = {
	  modifier = "Mod4";
          terminal = "${pkgs.termite}/bin/termite";
	  fonts = [ "${pfont} 11" ];
	  input."1739:30383:DELL07E6:00_06CB:76AF_Touchpad" = {
	    click_method = "clickfinger";
	    tap = "enabled";
	    dwt = "enabled";
	    scroll_method = "two_finger";
	    natural_scroll = "enabled";
	    accel_profile = "adaptive";
	    pointer_accel = "1";
          };
	  keybindings = {
	    # output scale change keybinding
	  };
	  wrapperFeatures = { gtk = true; };
	  bars = [
	    {
	      fonts = [ "${pfont} 9" ];
	      position = "top";
	      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
	    }
	  ];
	  menu = ''
	    # insert here
	  '';
	};
      };
      xdg.configFile = {
        "i3status-rust/config.toml".source = ../dotfiles/config/i3status-rust/config.toml;
        "wayvnc/config".source = ../dotfiles/config/wayvnc/vnc.cfg;
      };
      home.packages = with pkgs; [
        calibre
        evince
        fractal
        wlfreerdp
        gimp
        mpv
        gnome3.nautilus
        termite
        vscodium

	# fonts
        corefonts
	noto-fonts noto-fonts-extra noto-fonts-emoji
	numix-icon-theme arc-theme

        # sway
        swaybg swayidle swaylock # TODO: needed with hm module?
        xwayland i3status-rust slurp grim wf-recorder
        udiskie termite drm_info
        imv mako redshift-wayland
        wayvnc wl-clipboard wl-gammactl

        # browsers
        firefox firefoxNightly
        chromium # chromiumDevOzone #TODO

        # comms
        thunderbird
        fractal quaternion spectral

        # utils/misc
        brightnessctl
        pavucontrol
	pulsemixer
        qt5.qtwayland

        # stream stuff # TODO: how to do this correctly with HM maybe?
        obs-studio
        obs-wlrobs
        obs-v4l2sink

        # appearance
        arc-icon-theme arc-theme numix-icon-theme hicolor-icon-theme

        # <nonfree> ewwwww...
        discord slack spotify ripcord
        google-chrome-dev
        # </nonfree>
      ] ++ lib.optionals (config.system == "x86_64-linux")
        [ 
          intel-gpu-tools
        ];
    };
  };
}
