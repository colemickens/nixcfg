{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.tmux = {
        enable = true;

        # what the fuck?
        # terminal = "screen-256color";

        historyLimit = 100000;
        escapeTime = 0;
        keyMode = "vi";
        #mouseBindings = true; # TODO
        newSession = true;
        sensibleOnTop = true;
        extraConfig = ''
          set -g mouse on
        '';
      };
    };
  };
}

