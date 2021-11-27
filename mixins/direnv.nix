{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
        stdlib = ''
          # $HOME/.config/direnv/direnvrc
          : ''${XDG_CACHE_HOME:=$HOME/.cache}
          pwd_hash=$(echo -n $PWD | sha256sum | cut -d ' ' -f 1)
          direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
        '';
      };
    };
  };
}
