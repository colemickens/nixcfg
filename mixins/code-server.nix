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
      host = "0.0.0.0";
      auth = "none";
    };
  };
}

