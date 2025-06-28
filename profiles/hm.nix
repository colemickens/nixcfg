{ pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default # "home-manager"
    inputs.sops-nix.nixosModules.default # "sops"
  ];

  config = {
    services.dbus.packages = [ pkgs.dconf ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      users.cole =
        { pkgs, ... }@hm:
        {
          home.extraOutputsToInstall = [
            "info"
            "man"
            "share"
            "icons"
            "doc"
          ];
          home.stateVersion = "21.11";
          manual = {
            manpages.enable = false;
          };
          news.display = "silent";
          programs = {
            home-manager.enable = true;
          };
        };
    };
  };
}
