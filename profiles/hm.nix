{ pkgs, lib, config, inputs, ... }:

# includes ci devshell nativeBuildInputs - see bottom
{
  imports = [
    inputs.home-manager.nixosModules.default # "home-manager"
    inputs.sops-nix.nixosModules.default # "sops"
  ];

  config = {
    services.dbus.packages = with pkgs; [ pkgs.dconf ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      
      users.cole = { pkgs, ... }@hm: {
        home.extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
        home.stateVersion = "21.11";
        manual = { manpages.enable = false; };
        news.display = "silent";
        programs = {
          home-manager.enable = true;
        };

        sops = {
          gnupg.home = hm.config.programs.gpg.homedir;
        };
      };
    };
  };
}
