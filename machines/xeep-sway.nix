{ pkgs, ... }:

{
  imports = [
    ./xeep-base.nix
    ../modules/profile-sway.nix
  ];

  config = {
    environment.variables = {
      #MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };
  };
}
