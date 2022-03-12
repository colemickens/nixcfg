{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services.lorri = {
        enable = true;
      };
    };
  };
}
