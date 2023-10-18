{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
          # TODO: investigate if we can use nushellIntegration here
          # or if it conflicts with my stuff?
        };
        # use global gitignore so we keep GC roots per-project instead
        # stdlib = ''
        #   # $HOME/.config/direnv/direnvrc
        #   : ''${XDG_CACHE_HOME:=$HOME/.cache}
        #   pwd_hash=$(echo -n $PWD | sha256sum | cut -d ' ' -f 1)
        #   direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
        # '';
      };
    };
  };
}
