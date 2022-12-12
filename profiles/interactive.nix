{ pkgs, lib, config, inputs, ... }:

# includes ci devshell nativeBuildInputs - see bottom
{
  imports = [
    ./core.nix # imports hm

    ../secrets

    ../mixins/gpg-agent.nix

    ../mixins/aria2.nix
    # ../mixins/broot.nix
    ../mixins/cachix.nix
    # ../mixins/direnv.nix
    ../mixins/gh.nix
    ../mixins/gopass.nix
    ../mixins/helix.nix
    # ../mixins/ion.nix
    ../mixins/jj.nix
    # ../mixins/joshuto.nix
    # ../mixins/lorri.nix
    ../mixins/nushell.nix
    ../mixins/pijul.nix
    # ../mixins/skim.nix
    # ../mixins/solo2.nix
    # ../mixins/starship.nix
    ../mixins/sshd.nix
    ../mixins/tailscale.nix
    ../mixins/xdg.nix
    ../mixins/zellij.nix
    # ../mixins/zoxide.nix
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
        git.enable = true;
        neovim.enable = true;
      };
      home.packages = with pkgs; [
        (pkgs.callPackage ../pkgs/commands.nix { })

        # <rust pkgs>
        # https://zaiste.net/posts/shell-commands-rust/
        bottom
        # zenith # uh oh, no aarch64 support? noooooo
        bat
        tealdeer
        du-dust
        dua
        dufs # rust static file server
        exa
        fd
        gitui
        # gex
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

        prs

        nix-output-monitor

        pipes-rs

        xplr
        difftastic
        just
        pueue

        binwalk
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

        mosh
        # nix-tree nix-du ncdu nix-prefetch nixpkgs-review
        # mitmproxy
        # ? git-absorb
      ]
      ++ lib.optionals (pkgs.hostPlatform.system == "x86_64-linux")
        [ ]
      ++ lib.optionals (pkgs.hostPlatform.system == "aarch64-linux")
        [ ]
      ++ inputs.self.devShells.${pkgs.hostPlatform.system}.ci.nativeBuildInputs
      ;
    };
  };
}
