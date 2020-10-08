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

    ../mixins/cachix.nix
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
        direnv = {
          enable = true;
          enableNixDirenvIntegration = true;
          stdlib = ''
            # $HOME/.config/direnv/direnvrc
            : ''${XDG_CACHE_HOME:=$HOME/.cache}
            pwd_hash=$(echo -n $PWD | sha256sum | cut -d ' ' -f 1)
            direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
          '';
        };
        git.package = pkgs.gitAndTools.gitFull;
        gpg.enable = true;
        htop.enable = true;
      };
      home.packages = with pkgs; [
        fish
        
        #nixops
        asciinema
        wget curl rsync
        ripgrep jq fzf
        wget curl stow ncdu tree
        git-crypt gopass gnupg passrs ripasso-cursive
        openssh autossh mosh sshuttle
        gist tig #git-absorb
        github-cli
        cvs mercurial subversion
        #mitmproxy
        nix-du pv
        dnsutils
        usbutils
        yubico-piv-tool

        # https://zaiste.net/posts/shell-commands-rust/
        tealdeer ytop
        du-dust
        fd
        #grex # regex

        sops age cryptsetup
        meli

        #bottom
        htop iotop which binutils.bintools
        parallel unzip xz zip
        gomuks #rumatui

        nix-prefetch  nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2 spotify-tui

        gdb lldb file gptfdisk
        parted psmisc wipe

        aria2 megatools youtube-dl plowshare

        # eh?
        cordless
        xdg_utils
      ]
      ++ builtins.attrValues customCommands
      ++ lib.optionals (pkgs.system == "x86_64-linux") [pkgs.bandwidth]
      ;
    };
  };
}
