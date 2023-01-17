{ pkgs, lib, config, inputs, ... }:

# includes ci devshell nativeBuildInputs - see bottom
{
  imports = [
    inputs.home-manager.nixosModules.default # "home-manager"
    ./core.nix # (common + bottom,ssh,sshd,tailscale)

    ../secrets

    # ../mixins/common.nix

    ../mixins/aria2.nix
    ../mixins/bottom.nix
    ../mixins/cachix.nix
    ../mixins/gh.nix
    ../mixins/git.nix
    ../mixins/gopass.nix
    ../mixins/gpg-agent.nix
    ../mixins/helix.nix
    ../mixins/jj.nix
    ../mixins/joshuto.nix
    ../mixins/nushell.nix
    ../mixins/pijul.nix
    ../mixins/skim.nix
    ../mixins/ssh.nix
    ../mixins/xdg.nix
    # ../mixins/xplr.nix
    ../mixins/zellij.nix
    # ../mixins/zenith.nix
    ../mixins/zsh.nix
  ];
  # unusedImports = [
  #   ../mixins/ion.nix
  #   ../mixins/lorri.nix
  #   ../mixins/solo2.nix
  #   ../mixins/starship.nix
  #   ../mixins/zoxide.nix
  # ];

  config = {
    # I don't think my user dbus socket is here without this?????
    users.users.cole.linger = true;
    users.users.cole.shell = pkgs.zsh;

    sops.secrets = {
      "nixup-secrets".owner = "cole";
      "home-assistant-bearer-token".owner = "cole";
      "tailscale-join-authkey".owner = "cole";
      "oraclecloud_colemickens_privkey".owner = "cole";
      "oraclecloud_colemickens2_privkey".owner = "cole";
    };

    services.dbus.packages = with pkgs; [ pkgs.dconf ];
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.cole = { pkgs, ... }@hm: {
        home.extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
        home.stateVersion = "21.11";
        home.sessionVariables = {
          EDITOR = "hx";
          CARGO_HOME = "${hm.config.xdg.dataHome}/cargo";
          PARALLEL_HOME = "${hm.config.xdg.configHome}/parallel";
          PASSWORD_STORE_DIR = "${hm.config.xdg.dataHome}/password-store";
        };
        home.file = {
          "${hm.config.home.sessionVariables.PARALLEL_HOME}/will-cite".text = "";
          "${hm.config.home.sessionVariables.PARALLEL_HOME}/runs-without-willing-to-cite".text = "10";
        };
        manual = { manpages.enable = false; };
        news.display = "silent";
        programs = {
          home-manager.enable = true;
          gpg.enable = true;
        };
        home.file = {
          "${hm.config.xdg.configHome}/gdb/gdbinit".source = (pkgs.writeText "gdbinit" ''set auto-load safe-path /nix/store'');
        };
        programs = {
          git.enable = true;
          neovim.enable = true;
        };
        home.packages = lib.mkMerge [
          (lib.mkIf (pkgs.hostPlatform.system == "x86_64-linux") (with pkgs; [
            zenith # uh oh, no aarch64 support? noooooo
          ]))
          (lib.mkIf (pkgs.hostPlatform.system == "aarch_64-linux") (with pkgs; [ ]))
          # ++ inputs.self.devShells.${pkgs.stdenv.hostPlatform.system}.ci.nativeBuildInputs
          (with pkgs; [
            (pkgs.callPackage ../pkgs/commands.nix { })

            # <rust pkgs>
            # https://zaiste.net/posts/shell-commands-rust/
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
            # dogdns # build error and we dont use
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
            lsof
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
          ])
        ];
      };
    };
  };
}
