{ pkgs, config, ... }:

let
  nixiosk = import ../../imports/nixiosk;
in
{
  imports = [
    "${nixiosk}/configuration.nix"
  ];

  config = {
    nixiosk = {
      hardware = "raspberryPi4";
      program = {
        package = pkgs.firefox;
        executable = "/bin/firefox";
      };
      hostName = "couchpie";
      localSystem = { system = builtins.currentSystem; };
    };
  };
}
