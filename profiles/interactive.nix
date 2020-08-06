{ pkgs, lib, config, inputs, isFlakes, ... }:

let
  findImport = (import ../../../lib.nix).findImport;
  homeImport = (
    if isFlakes
    then inputs.home.nixosModules."home-manager"
    else "${findImport "extras/home-manager"}/nixos"
  );

  #nixops = inputs.nixops.pkgs.nixops;

  crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
  crtFile = pkgs.copyPathToStore crtFilePath;

  extraCommands = import ./extra/commands.nix {inherit pkgs; };
in
{
  imports = [
    ./core.nix  # imports hm

    ../mixins/gpg-agent.nix

    #../mixins/cachix/cachix.nix
    ../mixins/gopass/gopass.nix
    #../mixins/mega/mega.nix
    ../mixins/nushell.nix
    ../mixins/xdg.nix
  ];

  config = {
    # HM: ca.desrt.dconf error:
    services.dbus.packages = with pkgs; [ gnome3.dconf ];
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    home-manager.useGlobalPkgs = true;
    home-manager.users.cole = { pkgs, ... }: {
      home.stateVersion = "20.03";
      home.sessionVariables = {
        EDITOR = "${pkgs.neovim}/bin/nvim";
      };
      home.file = {
        ".gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
      };
      programs = {
        direnv.enable = true;
        git.package = pkgs.gitAndTools.gitFull;
        gpg.enable = true;
        htop.enable = true;
      };
      home.packages = with pkgs; [
        #nixops
        asciinema
        wget curl
        ripgrep jq fzf
        wget curl stow ncdu tree
        git-crypt gopass gnupg passrs ripasso-cursive
        openssh autossh mosh sshuttle
        gitAndTools.hub gist tig #git-absorb
        cvs mercurial subversion
        #mitmproxy
        nix-du

        # https://zaiste.net/posts/shell-commands-rust/
        dust tealdeer ytop
        bandwidth
        fd
        #grex # regex

        sops

        htop iotop which binutils.bintools
        unrar parallel unzip xz zip
        gomuks #rumatui

        nix-prefetch  nixpkgs-review

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
