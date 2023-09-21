{ config, lib, pkgs }:

let
  cfg = config.rtsp-simple-server;

  initScript = pkgs.writeShellScript "hydra-auto.sh" ''
    # for each in ${cfg.admins}
    sudo -u hydra -- ${pkgs.hydra-dev}/bin/hydra-create-user \
      "${username}" --full-name "${username}" \
      --email-address "${email}" --password "${password}" \
      --role admin

    # for each in ${cfg.projects}
    LOGIN="{\"username\":\"cole\", \"password\": \"cole\"}"
    ${pkgs.curl}/bin/curl \
      -b /tmp/cookie -c /tmp/cookie \
      -d "${LOGIN}" -X 'POST' -H 'Content-Type: application/json' \
      --referer 'http://localhost:3000/' \
      http://localhost:3000/login

    JSON="${newProject p}"
    ${pkgs.curl}/bin/curl \
      -b /tmp/cookie -c /tmp/cookie \
      -d "${JSON}" -X 'PUT' -H 'Content-Type: application/json' \
      --referer 'http://localhost:3000/' \
      http://localhost:3000/project/${projectName}
  '';

  options = {
    
  };

in {
  inherit options;

  config = {
    systemd.services."rtsp-simple-server" = {
      # todo: auto start after hydra

      serviceConfig = {
        WantedAfter = "hydra-init.service";
      };
    };
  };
}
