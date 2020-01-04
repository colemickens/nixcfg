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

      jrePackage = pkgs.jre8_headless;
      #jrePackage = pkgs.jre8_headless.override {
      #  swingSupport = false; # don't need swing things
      #  guiSupport = false;   # don't need GUI things
      #};

      #mongodbPackage = pkgs.mongodb.override {
      #  jsEngine = "none";    # can't cross compile mozjs
      #  allocator = "system"; # can't cross compile gperftools
      #};
    };

    networking.firewall.allowedTCPPorts = [ 8080 8443 ];
  };
}
