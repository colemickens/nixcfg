{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  hostname = "slynux.mickens.us";
in
{
  imports = [
    inputs.harmonia.nixosModules.harmonia
  ];
  
  config = {
    sops.secrets."harmonia-signing-key-slynux" = {
      owner = "nginx";
      group = "nginx";
      sopsFile = ../../secrets/encrypted/harmonia-signing-key-slynux;
      format = "binary";
    };
    services.harmonia-dev = {
      cache = {
        enable = true;
        signKeyPaths = [ config.sops.secrets.harmonia-signing-key-slynux.path ];
      };
    };
    services.nginx.virtualHosts."harmonia.${hostname}" = {
      listen = [
        {
          port = 443;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];

      addSSL = true;
      useACMEHost = "${hostname}";
      #root = "/var/www/${hostname}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:5000/";
        proxyWebsockets = true;
      };
    };
  };
}
