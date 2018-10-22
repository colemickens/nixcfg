{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userOptions.cole;
  pubkeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== cardno:000607532298"
  ];
in
{
  options = {
    userOptions.cole = {
      bashColor = mkOption { type = types.string; default = "1;32"; };
      tmuxColor = mkOption { type = types.string; default = "green"; };
    };
  };

  config = {
    # bare minimum applications I expect to be available:
    environment.systemPackages = with pkgs; [ tmux git neovim htop ripgrep jq ];

    nix.trustedUsers = [ "cole" ];

    i18n = {
      consoleKeyMap = "us";
      defaultLocale = "en_US.UTF-8";
    };

    programs.bash.enableCompletion = true;
    programs.bash.promptInit = ''
      # Provide a nice prompt.
      PROMPT_COLOR="1;31m"
      let $UID && PROMPT_COLOR="${cfg.bashColor}m"
      PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
      if test "$TERM" = "xterm"; then
        PS1="\[\033]2;\h:\u:\w\007\]$PS1"
      fi
    '';
    programs.bash.interactiveShellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
      export EDITOR="nvim"
      alias _nixup="sudo nixos-rebuild switch --option build-cores 0 --option extra-binary-caches \"https://nixcache.cluster.lol https://cache.nixos.org\" --option trusted-public-keys \"nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=\"";
      alias _sway="export WLR_DRM_NO_ATOMIC=1; sway -d &> ~/.local/sway-$(date '+%s').log";
      function _reset_pinentry () { pkill pinentry; echo 'UPDATESTARTUPTTY' | gpg-connect-agent; export GPG_TTY=$(tty); }

      export SSH_PUBLIC_KEY="${builtins.elemAt pubkeys 0}"
      if [[ "$SSH_AUTH_SOCK" == "/run/user/$(id -u)/keyring/ssh" ]]; then
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
      fi
    '';
    programs.ssh.startAgent = false;
    programs.tmux = {
      enable = true;
      extraTmuxConf = ''
        set -g status-style "bg=${cfg.tmuxColor}"
        set -g mouse
        set -g pane-border-fg ${cfg.tmuxColor}
        set -g pane-active-border-fg ${cfg.tmuxColor}
        set -g pane-active-border-bg ${cfg.tmuxColor}
        set-option -sg escape-time 10

        set -g default-terminal "xterm-256color"
        set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';
    };

    # TODO: split common into parts so we don't need to do this here
    security.sudo.wheelNeedsPassword = false;

    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      hashedPassword = "$6$rIU9KB8Q$2tHIz6wzkAGqM.F7IMjO9dyQzNeo7ksAUDOesw6pcr2AGD9lXqLHIKwZ0g/gIFSP59i06fZguavOtgUttiq6d.";
      shell = "/run/current-system/sw/bin/bash";
      extraGroups = [ "wheel" "networkmanager" "kvm" "libvirtd" "docker" "transmission" "audio" "video" "sway" "sound" "pulse" "input" ];
      uid = 1000;
      group = "cole";
      openssh.authorizedKeys.keys = pubkeys;
    };
  };
}

