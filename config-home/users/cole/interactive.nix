{ pkgs, lib, config, ... }:

let
#  cachixManual = import ./pkgs-cachix.nix pkgs;

  findImport = (import ../../../lib.nix).findImport;
  home-manager = findImport "extras" "home-manager";

  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore crtFilePath;
in
{
  imports = [
    ./core.nix
    "${home-manager}/nixos"
  ];

  config = {
    # <mitmproxy>
    security.pki.certificateFiles =
      if (lib.pathExists "${crtFilePath}")
        then [ "${crtFile}" ]
        else [];
    # </mitmproxy>

    # HM: ca.desrt.dconf error:
    services.dbus.packages = with pkgs; [ gnome3.dconf ];

    home-manager.useGlobalPkgs = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "nvim";
        TERMINAL = "alacritty";
      };
      home.file = {
        ".gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
        #".local/bin/gpgssh.sh".source = ./config/bin/gpgssh.sh;
        #".local/bin/megadl.sh".source = ./config/bin/megadl.sh;
        #".local/bin/rdpsly.sh".source = ./config/bin/rdpsly.sh;
      };
      xdg.enable = true;
      xdg.userDirs = {
        enable = true;
        desktop = "$HOME/data/desktop";
        documents = "$HOME/data/documents";
        download = "$HOME/data/downloads";
        music = "$HOME/data/music";
        pictures = "$HOME/data/pictures";
        publicShare = "$HOME/data/public";
        templates = "$HOME/data/templates";
        videos = "$HOME/data/videos";
      };
      xdg.configFile = {
        "gopass/config.yml".source = ./config/gopass/config.yml;
        # TODO: passrs ?
      };
      programs.gpg.enable = true;
      home.packages = with pkgs; [
        # everything non-gui goes here that I use
        #cachixManual
        wget curl
        # neovim vim # HM modules
        ripgrep jq fzf
        wget curl stow ncdu tree
        git-crypt gopass gnupg passrs
        openssh autossh mosh sshuttle
        gitAndTools.gitFull gitAndTools.hub gist tig
        cvs mercurial subversion

        nushell
        mitmproxy

        htop iotop which binutils.bintools
        unrar parallel unzip xz zip

        nix-prefetch nixpkgs-fmt nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2 spotify-tui

        gdb lldb file gptfdisk
        parted psmisc wipe

        aria2 megatools youtube-dl plowshare

        # eh?
        xdg_utils
      ];
    };
  };
}
