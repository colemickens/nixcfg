{ config
, pkgs
, lib
, modulesPath
, inputs
, ...
}:
let
  hs = "nixoorrxe2yyjab7ufuua6dsbcrbxe4ysb7q3t4iirxtvpa7d6bebxad";

  template = pkgs.writeText "template.html" ''
    <pre>nixos + sops-nix + tor = &lt;3 !asdf</pre>
    <pre>Hello from [@systemLabel@]!</pre>
  '';

  payload = pkgs.substituteAll {
    name = "index.html";
    src = template;
    dir = "/";
    systemLabel = config.system.nixos.label;
  };
in
{
  config = {
    services.nginx.enable = true;
    services.nginx.virtualHosts."default" = {
      root = payload;
      default = true;
    };

    services.tor.enable = true;
    services.tor.hiddenServices = {
      "${hs}" = {
        keyPath = config.sops.secrets."${hs}.key".path;
        map = [
          {
            port = "80";
            toPort = "80";
          }
        ];
      };
    };

    # doesn't work for us
    systemd.services.tor = {
      serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ]; # we shouldn't need this AND owner/mode below tho?
    };
    users.extraUsers.tor.extraGroups = [ config.users.groups.keys.name ];

    sops.secrets."${hs}.key" = {
      owner = "tor";
      group = "tor";
    };
  };
}
