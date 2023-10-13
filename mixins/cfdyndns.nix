{ config, pkgs, ... }:

{
  config = {
    sops.secrets."cf-apitoken-mickens_us" = {
      # owner = "cole";
      # group = "cole";
      sopsFile = ../secrets/encrypted/cf-apitoken-mickens_us;
      format = "binary";
    };
    services.cfdyndns = {
      enable = true;
      apiTokenFile = config.sops.secrets."cf-apitoken-mickens_us".path;
      records = [ "${config.networking.hostName}.hosts.mickens.us" ];
    };
  };
}
