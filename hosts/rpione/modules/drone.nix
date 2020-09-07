{ pkgs, config, ... }:

let
  droneserver = config.users.users.droneserver.name;
  host = "drone.invariant.tech";
in {
  systemd.services.drone-server = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_SERVER_PORT=:3030"
        "DRONE_SERVER_HOST=${host}"
        "DRONE_SERVER_PROTO=http"
        "DRONE_LOGS_DEBUG=true"

        "DRONE_DATABASE_DATASOURCE=postgres:///droneserver?host=/run/postgresql"
        "DRONE_DATABASE_DRIVER=postgres"
        "DRONE_SERVER_PORT=:3030"
        "DRONE_USER_CREATE=username:colemickens,admin:true"
      ];
      EnvironmentFile = [
        config.sops.secrets."drone.env".path
      ];
      ExecStart = "${pkgs.drone}/bin/drone-server";
      User = droneserver;
      Group = droneserver;
    };
  };

  services.postgresql = {
    ensureDatabases = [ droneserver ];
    ensureUsers = [{
      name = droneserver;
      ensurePermissions = {
        "DATABASE ${droneserver}" = "ALL PRIVILEGES";
      };
    }];
  };
  
  services.nginx.virtualHosts."${host}" = {
    #useACMEHost = "invariant.tech";
    #forceSSL = true;
    listen = [ { addr = "0.0.0.0"; port = 80; } ];
    locations."/".extraConfig = ''
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $host;
      proxy_pass http://localhost:3030;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_buffering off;

      chunked_transfer_encoding off;
    '';
  };

  systemd.services.drone-agent = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = [
        "DRONE_SERVER_PORT=:3030"
        "DRONE_RUNNER_NETWORKS=bridge"
      ];
      EnvironmentFile = [ config.sops.secrets."drone.env".path ];
      ExecStart = "${pkgs.drone}/bin/drone-agent";
      User = "drone-agent";
      Group = "drone-agent";
      SupplementaryGroups = [ "docker" ];
      RuntimeDirectory = "drone";
      DynamicUser = true;
    };
  };

  users.users.droneserver = {
    isSystemUser = true;
    createHome = true;
    group = droneserver;
  };
  users.groups.droneserver = {};
}