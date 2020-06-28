{ pkgs, lib, config, inputs, isFlakes, ... }:

let
  findImport = (import ../../../lib.nix).findImport;
  hmImport = (
    if isFlakes
    then inputs.home.nixosModules."home-manager"
    else "${findImport "extras" "home-manager"}/nixos"
  );

  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore crtFilePath;
  
  extraCommands = import ./extra/commands.nix {inherit pkgs; };
in
{
  imports = [
    ./core.nix
    hmImport
  ];

  config = {
    # HM: ca.desrt.dconf error:
    services.dbus.packages = with pkgs; [ gnome3.dconf ];

    home-manager.useGlobalPkgs = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "${pkgs.neovim}/bin/nvim";
      };
      home.file = {
        ".gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
        #".local/bin/gpgssh.sh".source = ./config/bin/gpgssh.sh;
        #".local/bin/megadl.sh".source = ./config/bin/megadl.sh;
        ".megarc".source = ./config/mega/megarc;
      };
      services.lorri.enable = true;
      xdg.enable = true;
      xdg.userDirs.enable = true;
      xdg.userDirs.download = "$HOME/downloads";
      xdg.configFile = {
        "gopass/config.yml".source = ./config/gopass/config.yml;
        "cachix/cachix.dhall".source = ./config/cachix/cachix.dhall;
      };
      programs.git.package = pkgs.gitAndTools.gitFull;
      programs.gpg.enable = true;
      home.packages = with pkgs; [
        wget curl
        ripgrep jq fzf
        wget curl stow ncdu tree
        git-crypt gopass gnupg passrs
        openssh autossh mosh sshuttle
        gitAndTools.hub gist tig
        cvs mercurial subversion
        mitmproxy

        htop iotop which binutils.bintools
        unrar parallel unzip xz zip
        gomuks

        nix-prefetch nixpkgs-fmt nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2 spotify-tui

        gdb lldb file gptfdisk
        parted psmisc wipe

        aria2 megatools youtube-dl plowshare

        # eh?
        xdg_utils
      ] ++ builtins.attrValues customCommands;
    };
  };
}
