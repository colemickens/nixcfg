{ pkgs, lib, config, inputs, ... }:

# interactive2.nix is a snapshot copy of interactive.nix
# with the hope of getting a minimal version that cross-compiles

# but it seems that even qtbase is broken for cross-compiling so
# probably just abandoning this for now...

{
  imports = [
    inputs.home-manager.nixosModules.default # "home-manager"
    ./core.nix # (common + bottom,ssh,sshd,tailscale)
    ./hm.nix

    # ../mixins/aria2.nix
    # ../mixins/bottom.nix
    # ../mixins/cachix.nix
    # ../mixins/gh.nix
    ../mixins/git.nix
    # ../mixins/gopass.nix
    ../mixins/gpg-agent.nix
    # ../mixins/helix.nix
    # ../mixins/jj.nix
    # ../mixins/joshuto.nix
    # ../mixins/nushell.nix
    # ../mixins/pijul.nix
    # ../mixins/skim.nix
    # ../mixins/spotify.nix
    ../mixins/ssh.nix
    # ../mixins/xdg.nix
    # ../mixins/xplr.nix # TODO
    # ../mixins/zellij.nix
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
      "oraclecloud_colemickens_privkey".owner = "cole";
      "oraclecloud_colemickens2_privkey".owner = "cole";
    };

    services.dbus.packages = with pkgs; [ pkgs.dconf ];
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
          neovim.enable = (pkgs.hostPlatform.system != "riscv64-linux");
        };
        home.packages = lib.mkMerge [
          (lib.mkIf (pkgs.hostPlatform.system != "riscv64-linux") (with pkgs; [
            # x86_64-linux only
            zenith # uh oh, no aarch64 support? noooooo
            bandwhich # TODO: check if it natively compiles?
            procs # TODO: fix a bug report?

            parallel
            dufs
            rustscan
            tealdeer
            unar
            xh
            yt-dlp
            watchman
            wipe
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
            du-dust
            dua
            erdtree # erd - dua alternative
            exa
            fd
            gitui
            gex
            grex
            hexyl
            dogdns
            ripgrep
            jless
            sd
            prs
            pipes-rs
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
            file
            lsof
            p7zip # needed with unar??
            sops # age ?rage?
            step-cli
            gptfdisk
            parted
            iotop
            which
            binutils.bintools
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
