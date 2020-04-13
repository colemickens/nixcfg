{ config, pkgs, ... }:
let
  overlay = (import ../lib.nix).overlay;
in
{
  config = {
    nixpkgs.overlays = [
      (overlay "nixpkgs-wayland")
    ];

    programs.sway.enable = true;

    nix = {
      binaryCachePublicKeys = [ "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" ];
      binaryCaches = [ "https://nixpkgs-wayland.cachix.org" ];
      trustedUsers = [ "@wheel" "root" ];
    };

    environment.systemPackages = with pkgs; [
      alacritty
      cage
      swaybg
      swayidle
      swaylock
    ];
  };
}
