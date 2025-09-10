{ ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        home = {
          packages = with pkgs; [
            alejandra
            nil
            nixd
            nixfmt
            nixpkgs-review

            dfmt

            mergiraf
          ];
          sessionVariables = {
            ENVRC_USE_FLAKE = 1;
          };
        };
      };
  };
}
