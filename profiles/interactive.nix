{
  pkgs,
  lib,
  inputs,
  ...
}:

# includes ci devshell nativeBuildInputs - see bottom
{
  imports = [
    inputs.home-manager.nixosModules.default # "home-manager"
    ./core.nix # (common + bottom,ssh,sshd,tailscale)
    ./hm.nix

    ./commands.nix

    ../mixins/aria2.nix
    ../mixins/bash.nix
    ../mixins/bat.nix
    ../mixins/bottom.nix
    ../mixins/carapace.nix
    ../mixins/cachix.nix
    ../mixins/direnv.nix
    ../mixins/gh.nix
    ../mixins/git.nix
    ../mixins/gpg-agent.nix
    ../mixins/helix.nix
    ../mixins/jujutsu.nix
    ../mixins/nushell.nix
    ../mixins/ssh.nix
    ../mixins/xdg.nix
    ../mixins/zellij.nix
    ../mixins/zsh.nix
  ];

  config = {
    users.users.cole.linger = true;
    users.users.cole.shell = pkgs.zsh;

    programs.bandwhich.enable = true;

    services.dbus.packages = [ pkgs.dconf ];
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    home-manager = {
      users.cole =
        { pkgs, ... }@hm:
        {
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

          xdg.configFile."gdb/gdbinit".text = ''
            set auto-load safe-path /nix/store
          '';

          programs = {
            git.enable = true;
          };
          home.packages = lib.mkMerge [
            (lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") (
              with pkgs;
              [
                # x86_64-linux only
                cpuid
                zenith
              ]
            ))
            (lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch_64-linux") (
              with pkgs;
              [
                # aarch64-linux only
              ]
            ))
            # ++ inputs.self.devShells.${pkgs.stdenv.hostPlatform.system}.ci.nativeBuildInputs
            (with pkgs; [
              # yolo
              appimage-run

              # <rust pkgs>
              delta
              tealdeer
              cfspeedtest
              dust
              dua
              erdtree # erd - dua alternative
              dufs # rust static file server
              eza # eza-community replacement for exa
              fd
              fx
              gitui
              grex
              hexyl
              xh
              lazygit
              dogdns
              dig
              ripgrep
              jless
              sd
              procs
              prs
              pipes-rs
              rage
              rustscan
              xplr
              miniserve
              # </rust pkgs>

              nix-inspect
              nix-output-monitor

              erdtree

              age # need age (Age-keygen can do priv->pub)
              sbctl

              # binwalk # TODO: pynose/nose issue?
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
              p7zip
              sops
              # step-cli
              gptfdisk
              parted
              iotop
              which
              binutils.bintools
              parallel
              unzip
              xz
              zip
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

              powertop

              linuxPackages.cpupower

              yt-dlp
              imgurbash2

              mosh
            ])
          ];
        };
    };
  };
}
