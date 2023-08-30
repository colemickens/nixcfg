{ pkgs, lib, config, inputs, ... }:

# includes ci devshell nativeBuildInputs - see bottom
{
  imports = [
    inputs.home-manager.nixosModules.default # "home-manager"
    ./core.nix # (common + bottom,ssh,sshd,tailscale)
    ./hm.nix

    ../mixins/aria2.nix
    ../mixins/bottom.nix
    ../mixins/cachix.nix
    ../mixins/gh.nix
    ../mixins/git.nix
    ../mixins/gopass.nix
    ../mixins/gpg-agent.nix
    ../mixins/helix.nix
    # ../mixins/jj.nix
    ../mixins/joshuto.nix
    ../mixins/nushell.nix
    ../mixins/pijul.nix
    ../mixins/skim.nix
    ../mixins/spotify.nix
    ../mixins/ssh.nix
    ../mixins/xdg.nix
    # ../mixins/xplr.nix # TODO
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
      "oraclecloud_colemickens_privkey" = {
        owner = "cole";
        sopsFile = ../secrets/encrypted/oraclecloud_colemickens_privkey;
        format = "binary";
      };
      "oraclecloud_colemickens2_privkey" = {
        owner = "cole";
        sopsFile = ../secrets/encrypted/oraclecloud_colemickens2_privkey;
        format = "binary";
      };
    };

    services.dbus.packages = with pkgs; [ pkgs.dconf ];
    security = {
      please.enable = true;
      please.wheelNeedsPassword = false;
    };
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    home-manager = {
      users.cole = { pkgs, ... }@hm: {
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
          (lib.mkIf (pkgs.hostPlatform.system != "riscv64-linux") (with pkgs; [
            # x86_64-linux only
            zenith # uh oh, no aarch64 support? noooooo
            bandwhich # TODO: check if it natively compiles?
          ]))
          (lib.mkIf (pkgs.hostPlatform.system == "x86_64-linux") (with pkgs; [
            # x86_64-linux only
            zenith # uh oh, no aarch64 support? noooooo
          ]))
          (lib.mkIf (pkgs.hostPlatform.system == "aarch_64-linux") (with pkgs; [
            # aarch64-linux only
          ]))
          # ++ inputs.self.devShells.${pkgs.stdenv.hostPlatform.system}.ci.nativeBuildInputs
          (with pkgs; [
            (pkgs.callPackage ../pkgs/commands.nix { })

            # <rust pkgs>
            bat
            tealdeer
            cfspeedtest
            du-dust
            dua
            erdtree # erd - dua alternative
            dufs # rust static file server
            exa
            fd
            gitui
            gex
            grex
            hexyl
            xh
            dogdns
            ripgrep
            jless
            sd
            procs
            prs
            pipes-rs
            rage age # need age (Age-keygen can do priv->pub)
            rustscan
            # </rust pkgs>
            sbctl

            # nix-related (TODO move to devtools shell that gets pulled in)
            # nix-tree nix-du ncdu nix-prefetch nixpkgs-review
            nix-output-monitor

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
            watchman
            watchexec
            wireguard-tools
            ntfsprogs
            difftastic
            just
            # pueue

            powertop

            linuxPackages.cpupower
            # linuxPackages.usbip

            # aria2 # mixins/aria2.nix: home-manager module now
            yt-dlp
            imgurbash2

            mosh
            # mitmproxy
            # ? git-absorb
          ])
        ];
      };
    };
  };
}
