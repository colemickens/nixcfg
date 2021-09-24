{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/code-server.nix
  ];

  config = {
    code-server = {
      enable = true;
      domain = "${config.networking.hostName}.ts.r10e.tech";
      user = "cole";
    };
  };
}

