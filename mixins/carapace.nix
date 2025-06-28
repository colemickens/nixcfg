{ ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs = {
          carapace = {
            enable = true;
            enableNushellIntegration = true;
          };
        };
      };
  };
}
