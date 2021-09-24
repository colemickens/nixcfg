{ pkgs, lib, config, inputs, ... }:

let
#   crtFilePath = "/home/cole/.mitmproxy/mitmproxy-ca-cert.pem";
#   crtFile = pkgs.copyPathToStore crtFilePath;
  extraCommands = import ./extra/commands.nix {inherit pkgs; };
in
{
  imports = [
    ./core.nix  # imports hm

    ../secrets

    ../mixins/gpg-agent.nix

    ../mixins/cachix.nix
    ../mixins/direnv.nix
    ../mixins/gh.nix
    ../mixins/gopass/gopass.nix
    #../mixins/mega/mega.nix
    ../mixins/mcfly.nix
    ../mixins/nushell.nix
    ../mixins/skim.nix
    ../mixins/sshd.nix
    ../mixins/tailscale.nix
    ../mixins/xdg.nix
    ../mixins/zellij.nix
    ../mixins/zoxide.nix
  ];

  config = {
    # HM: ca.desrt.dconf error:
    # TODO: sops.secrets."nixup-secrets".owner = config.users.users.cole;
    sops.secrets."nixup-secrets".owner = "cole";

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
      };
      home.packages = with pkgs; [
        colePackages.customCommands

        #inputs.stable.legacyPackages.${pkgs.system}.cachix
        cachix

        #nixops
        screen minicom picocom
        asciinema
        wget curl rsync
        ripgrep jq fzy
        wget curl stow ncdu tree
        nix-tree
        #pdu
        git-crypt gopass
        #passrs ripasso-cursive

        openssh autossh mosh sshuttle
        tig #git-absorb
        github-cli
        git-lfs
        cvs mercurial subversion
        #mitmproxy
        #nix-du
        pv
        dnsutils
        usbutils
        yubico-piv-tool
        zellij

        tokei

        # https://zaiste.net/posts/shell-commands-rust/
        bat
        tealdeer
        du-dust
        fd
        grex # regex
        # more rust tools
        hexyl
        xh
        dogdns

        # random
        wireguard-tools
        pijul
        jj

        sops age cryptsetup

        #bottom
        iotop which binutils.bintools
        parallel unzip xz zip
        gomuks #rumatui
        oci-cli

        nix-prefetch  nixpkgs-review

        ffmpeg linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        imgurbash2

        gdb lldb file gptfdisk
        parted psmisc wipe

        aria2 megatools youtube-dl
        #plowshare

        # eh?
        cordless
        xdg_utils
        bb
        usbutils
        pciutils
        lshw
        efibootmgr
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [

      ] ++ lib.optionals (pkgs.system == "aarch64-linux") [
        #
      ]
      ;
    };
  };
}
