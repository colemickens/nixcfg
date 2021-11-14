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

    sops."openvscode-conn-token".owner = "cole";
    openvscode-server = {
      enable = true;
      connectionSecret = config.sops."openvscode-conn-token".path;
      user = "cole";
    };
  };
}

