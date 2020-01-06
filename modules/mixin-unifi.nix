{ pkgs, ... }:

{
  config = {
    nixpkgs.config = {
      allowUnfree = true;
      oraclejdk.accept_license = true;
    };

    services.unifi = {
      enable = true;
      unifiPackage = pkgs.unifiStable;

      mongodbPackage =
        let
          channelRelease = "nixos-19.09pre190687.3f4144c30a6";  # last known working mongo
          channelName = "unstable";
          url = "https://releases.nixos.org/nixos/${channelName}/${channelRelease}/nixexprs.tar.xz";
          sha256 = "040f16afph387s0a4cc476q3j0z8ik2p5bjyg9w2kkahss1d0pzm";

          pinnedNixpkgsFile = builtins.fetchTarball {
            inherit url sha256;
          };

          pinnedNixpkgs = import pinnedNixpkgsFile {};
        in pinnedNixpkgs.mongodb;

      jrePackage = pkgs.jre8_headless;
    };

    networking.firewall.allowedTCPPorts = [ 8080 8443 ];
  };
}
