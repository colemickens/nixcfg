{
  pkgs,
  config,
  inputs,
  ...
}:

# these are dev tools that we want available
# system wide on my dev machine(s)

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
            nixfmt-rfc-style

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
