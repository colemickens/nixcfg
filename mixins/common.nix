{ config, lib, pkgs, inputs, ... }:

with lib;

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ../secrets
  ];

  config = {
    i18n.defaultLocale = "en_US.UTF-8";

    boot = {
      tmpOnTmpfs = true;   # probably not appropriate for all machines (rpi)
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };

    environment.systemPackages = with pkgs; [ coreutils ];
    
    # TODO: root ssh config to get nix daemon to use user's gpg-agent for ssh (closer to gpg conf hopefully)

    nix = {
      buildCores = 0;
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

      package = pkgs.nixFlakes;
      extraOptions =
        lib.optionalString (config.nix.package == pkgs.nixFlakes)
          "experimental-features = nix-command flakes ca-references recursive-nix";
    };

    security.sudo.wheelNeedsPassword = false;
    users.mutableUsers = false;
    users.users."root".initialHashedPassword = lib.mkForce "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
    users.users."root".hashedPassword = config.users.users."root".initialHashedPassword;

    nixpkgs.overlays = [
      inputs.self.overlay
    ];
  };
}

