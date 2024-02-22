{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nixcfg.services.typhon;
in
{
  options = {
    nixcfg.services.typhon = {
      enable = lib.mkEnableOption "typhon";
    };
  };

  imports = [
    inputs.typhon.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3000 ];
    services.typhon.enable = true;
    services.typhon.hashedPassword = "$argon2id$v=19$m=4096,t=3,p=1$QUVZa2YvQmJNNkZ1SzFYM0Jlb2t2QT09$BA/+8HVku0UXb9nZvymJOrqGsgNLoVUjmyLkpX2Wpg4";
  };
}
