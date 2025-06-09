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

    ../mixins/fonts.nix
    ../mixins/mpv.nix
    # ../mixins/pam-u2f.nix # separate out briefly
    ../mixins/pipewire.nix
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

      let xdgFirefoxApp = profile: icon: hidden: ''
        [Desktop Entry]
        Actions=new-private-window;new-window;profile-manager-window
        Categories=Network;WebBrowser
        Exec=firefox -P ${profile} --name firefox %U
        GenericName=Web Browser
        Icon=${icon}
        MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https
        Name=${profile}
        StartupNotify=true
        StartupWMClass=firefox
        Terminal=false
        Type=Application
        Version=1.4
        Hidden=${builtins.toString hidden}

        [Desktop Action new-private-window]
        Exec=firefox-nightly --private-window %U
        Name=New Private Window

        [Desktop Action new-window]
        Exec=firefox-nightly --new-window %U
        Name=New Window

        [Desktop Action profile-manager-window]
        Exec=firefox-nightly --ProfileManager
        Name=Profile Manager
      '';
      in
      {
        home.sessionVariables = {
          BROWSER = "firefox";
        };
        
        xdg.dataFile."applications/firefox-default.desktop".text =
          xdgFirefoxApp "personal" "firefox" false;
        xdg.dataFile."applications/firefox-detsys.desktop".text =
          xdgFirefoxApp "detsys" "web-browser" false;
        xdg.dataFile."applications/firefox.desktop".text =
          xdgFirefoxApp "none" "firefox" true;

        services = {
          pass-secret-service = {
            enable = true;
            # verbose = true;
            # copied from profiles/interactive -> PASSWORD_STORE_DIR
            storePath = "${hm.config.xdg.dataHome}/password-store";
          };
          gpg-agent.pinentry.package = pkgs.wayprompt;
          gpg-agent.pinentry.program = "pinentry-wayprompt";
        };

        home.packages = lib.mkMerge [
          (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") (
            with pkgs;
            [
              # browsers
              pkgs.firefox-bin
              _chrome

              # audio/video
              jamesdsp
              easyeffects

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
            vlc

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
