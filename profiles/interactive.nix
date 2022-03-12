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
    ../mixins/gopass.nix
    ../mixins/helix.nix
    ../mixins/ion.nix
    ../mixins/jj.nix
    ../mixins/joshuto.nix
    ../mixins/lorri.nix
    # do I need this, use skim's support instead?
    # ../mixins/mcfly.nix # wish it took the history arg in config file
    ../mixins/nushell.nix
    ../mixins/pijul.nix
    ../mixins/skim.nix # weird aarch64 build error...?
    ../mixins/solo2.nix
    ../mixins/starship.nix
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

    sops.secrets."oraclecloud_colemickens_privkey".owner = "cole";
    sops.secrets."oraclecloud_colemickens2_privkey".owner = "cole";

    services.dbus.packages = with pkgs; [ pkgs.dconf ];
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    home-manager.users.cole = { pkgs, ... }@hm: {
      home.sessionVariables = {
      };
      home.file = {
        "${hm.config.xdg.configHome}/gdb/gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
      };
      programs = {
        git.package = pkgs.gitAndTools.gitFull;
      };
      home.packages = with pkgs; [
        colePackages.customCommands

        # TODO: remove the need for this
        cachix

        # <rust pkgs>
        # https://zaiste.net/posts/shell-commands-rust/
        bottom
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
        prs # gopass replacement, oh fuck thank god
        # </rust pkgs>
        python3Packages.pywatchman

        usbutils pciutils lshw
        efibootmgr cryptsetup
        wipe file unar
        sops # age ?rage?
        step-cli
        gptfdisk parted
        iotop which binutils.bintools
        parallel unzip xz zip
        picocom
        asciinema
        wget curl rsync wget curl jq
        openssh autossh mosh sshuttle

        linuxPackages.cpupower
        linuxPackages.usbip

        aria2 youtube-dl # TODO: remove whenever we get aria2->incoming setup
        imgurbash2

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
