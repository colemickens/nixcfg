{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/code-server.nix
    ../modules/openvscode-server.nix
  ];

  config = {
    code-server = {
      enable = true;
      user = "cole";
    };

    openvscode-server = {
      enable = true;
      user = "cole";
    };
  };
}

