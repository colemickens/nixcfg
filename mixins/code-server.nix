{ config, pkgs, lib, ... }:

{
  imports = [
  ];

  config = {
    services.code-server = {
      enable = true;
      user = "cole";
      group = "cole";

      port = 4444;
      auth = "none";
    };
  };
}

