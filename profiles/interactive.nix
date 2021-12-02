{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./core.nix  # imports hm

    ../secrets

    ../mixins/gpg-agent.nix

    ../mixins/broot.nix
    ../mixins/cachix.nix
    ../mixins/direnv.nix
    ../mixins/gh.nix
    ../mixins/gopass/gopass.nix
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
    sops.secrets."tailscale-join-authkey".owner = "cole";

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

        usbutils pciutils lshw
        efibootmgr cryptsetup
        sops age
        
        linuxPackages.cpupower
        sshfs cifs-utils ms-sys ntfs3g
        gdb lldb file gptfdisk
        parted psmisc wipe

        cachix
        screen minicom picocom
        asciinema
        wget curl rsync
        ripgrep jq fzy
        wget curl stow ncdu tree
        nix-tree
        #pdu
        git-crypt
        gopass
        #ripasso-cursive

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

        unar
        gitui

        # https://zaiste.net/posts/shell-commands-rust/
        bb
        bat
        tealdeer
        du-dust
        fd
        grex # regex
        # more rust tools
        hexyl
        xh
        dogdns
        jj

        iotop which binutils.bintools
        parallel unzip xz zip

        nix-prefetch  nixpkgs-review

        aria2 youtube-dl # TODO: remove whenever we get aria2->incoming setup
        imgurbash2
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [

      ] ++ lib.optionals (pkgs.system == "aarch64-linux") [
        #
      ]
      ;
    };
  };
}
