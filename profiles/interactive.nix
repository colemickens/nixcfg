{ pkgs, lib, config, inputs, isFlakes, ... }:

let
#   crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
#   crtFile = pkgs.copyPathToStore crtFilePath;
  extraCommands = import ./extra/commands.nix {inherit pkgs; };
in
{
  imports = [
    ./core.nix  # imports hm

    ../mixins/gpg-agent.nix

    ../mixins/cachix.nix
    ../mixins/direnv.nix
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
    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        EDITOR = "${pkgs.neovim}/bin/nvim";
      };
      home.file = {
        ".gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
      };
      programs = {
        git.package = pkgs.gitAndTools.gitFull;
        gpg.enable = true;
      };
      home.packages = with pkgs; [
        inputs.stable.legacyPackages.${pkgs.system}.cachix
        colePackages.customCommands

        #nixops
        asciinema
        wget curl rsync
        ripgrep jq fzf
        wget curl stow ncdu tree
        git-crypt gopass gnupg passrs ripasso-cursive
        openssh autossh mosh sshuttle
        tig #git-absorb
        gist # use `gh gist create` instead
        github-cli
        cvs mercurial subversion
        #mitmproxy
        nix-du pv
        dnsutils
        usbutils
        yubico-piv-tool

        # https://zaiste.net/posts/shell-commands-rust/
        tealdeer
        du-dust
        fd
        wireguard-tools
        #grex # regex

        sops age cryptsetup

        #bottom
        iotop which binutils.bintools
        parallel unzip xz zip
        gomuks #rumatui

        nix-prefetch  nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2 spotify-tui

        gdb lldb file gptfdisk
        parted psmisc wipe

        aria2 megatools youtube-dl
        #plowshare

        # eh?
        cordless
        xdg_utils
        lynis

        azure-cli
        #awscli2
      ]
      ++ (if pkgs.system != "x86_64-linux" then [] else [
      ])
      ;
    };
  };
}
