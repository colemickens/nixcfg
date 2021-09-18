{ pkgs, lib, config, inputs, ... }:

let
  # steamPkgs_ = inputs.nixos-unstable;
  # steamPkgs = import steamPkgs_ {
  #   inherit (pkgs) system;
  #   config.allowUnfree = true;
  # };
  steamPkgs = pkgs;
in {
  config = {
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = (pkgs.system=="x86_64-linux");
      };
    };
    
    # the module doesn't do much (we do the same) and we want to use slightly stable-r pkgs
    #programs.steam.enable = true;

    environment.systemPackages = with steamPkgs; [
      lutris
      #steam-run-native
      steam
      steam.run
      #wine
      wineWowPackages.staging
      winetricks
    ];
  };
}
