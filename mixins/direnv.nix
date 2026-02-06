{ inputs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.direnv = {
          enable = true;
          # TODO: investigate if we can use nushellIntegration here
          # enableNushellIntegration = true;

          # REVISIT: disable nix-direnv, since it uses a specific nix, that hits issues with lastModified
          nix-direnv = {
            enable = true;
            # package = (pkgs.nix-direnv.override {
            #   nix = inputs.determinate-nix-src.packages.${pkgs.stdenv.hostPlatform.system}.default;
            # });
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
