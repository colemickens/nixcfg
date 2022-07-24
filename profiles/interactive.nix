{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./core.nix # imports hm

    ../secrets
    
    ../mixins/gpg-agent.nix

    ../mixins/aria2.nix
    ../mixins/broot.nix
    ../mixins/cachix.nix
    ../mixins/direnv.nix
    # ../mixins/gh.nix
    ../mixins/gopass.nix
    ../mixins/helix.nix
    ../mixins/ion.nix
    ../mixins/jj.nix
    ../mixins/joshuto.nix
    ../mixins/lorri.nix
    ../mixins/nushell.nix
    ../mixins/pijul.nix
    ../mixins/skim.nix
    ../mixins/solo2.nix
    ../mixins/starship.nix
    ../mixins/sshd.nix
    ../mixins/tailscale.nix
    ../mixins/xdg.nix
    ../mixins/zellij.nix
    ../mixins/zoxide.nix
  ];

  config = {
    # I don't think my user dbus socket is here without this?????
    users.users.cole.linger = true;
    users.users.cole.shell = pkgs.zsh;
    
    # HM: ca.desrt.dconf error:
    # TODO: sops.secrets."nixup-secrets".owner = config.users.users.cole;
    sops.secrets."nixup-secrets".owner = "cole";
    sops.secrets."home-assistant-bearer-token".owner = "cole";
    sops.secrets."tailscale-join-authkey".owner = "cole";

    sops.secrets."oraclecloud_colemickens_privkey".owner = "cole";
    sops.secrets."oraclecloud_colemickens2_privkey".owner = "cole";

    services.dbus.packages = with pkgs; [ pkgs.dconf ];
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    home-manager.users.cole = { pkgs, ... }@hm: {
      home.sessionVariables = { };
      home.file = {
        "${hm.config.xdg.configHome}/gdb/gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
      };
      programs = {
        git.package = pkgs.gitAndTools.gitFull;
      };
      home.packages = with pkgs; [
        colePackages.customCommands

        # <rust pkgs>
        # https://zaiste.net/posts/shell-commands-rust/
        bottom
        # zenith # uh oh, no aarch64 support? noooooo
        bat
        tealdeer
        du-dust
        dua
        exa
        fd
        gitui
        grex
        hexyl
        xh
        dogdns
        ripasso-cursive
        ripgrep
        jless
        sd
        procs
        bandwhich
        #sfz # simple file zerver? lol
        # prs # gopass replacement, oh fuck thank god, but no TOTP or PASSWORD_STORE_DIR or sequoia support
        # </rust pkgs>
        python3Packages.pywatchman
        watchman
        watchexec
        tpm2-tools
        
        cava
        cli-visualizer
        
        pipes-rs

        xplr
        difftastic
        just
        pueue
        
        cpio # needed?
        usbutils
        pciutils
        dmidecode
        lshw
        nvme-cli
        efibootmgr
        mokutil
        cryptsetup
        wipe
        file
        unar
        p7zip # needed with unar??
        sops # age ?rage?
        step-cli
        gptfdisk
        parted
        iotop
        which
        binutils.bintools
        parallel
        unzip
        xz
        zip
        picocom
        asciinema
        wget
        curl
        rsync
        wget
        curl
        jq
        openssh

        linuxPackages.cpupower
        linuxPackages.usbip

        # aria2 # mixins/aria2.nix: home-manager module now
        yt-dlp
        imgurbash2

        # autossh
        # mosh
        # sshuttle
        # nix-tree nix-du ncdu nix-prefetch nixpkgs-review
        # git-crypt
        # mitmproxy
        # sshfs cifs-utils ms-sys ntfs3g
        # github-cli cvs mercurial subversion git-lfs
        # ? git-absorb
      ]
      ++ lib.optionals (pkgs.system == "x86_64-linux") [

      ] ++ lib.optionals (pkgs.system == "aarch64-linux") [
        #
      ]
      ;
    };
  };
}
