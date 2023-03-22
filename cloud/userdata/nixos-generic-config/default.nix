#!nix
{ config, lib, pkgs, inputs, ... }:

{
  config = {
    boot = {
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.file-max" = 2147483584;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };
    environment.systemPackages = with pkgs; [
      coreutils
      cachix
      bottom
    ];
    nix = {
      # i weep, i cry
      # https://nixos.org/manual/nix/unstable/advanced-topics/cores-vs-jobs.html
      # buildCores = 0; # YOLO
      binaryCachePublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      binaryCaches = [
        "https://cache.nixos.org"
        "https://colemickens.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trustedUsers = [ "@wheel" "root" ];
      package = pkgs.nixUnstable;
      extraOptions = "experimental-features = nix-command flakes recursive-nix";
    };

    security.sudo.wheelNeedsPassword = false;
    users.mutableUsers = false;
  };
}

