{ config, lib, pkgs }:

# TODO: This is like 30% half-fleshed out, never run/tested, etc, needs a lot of love

let
  cfg = config.hydra-auto;

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
    # option for autoAdmin
    # option for autoProjects
    # option for the endpoint
    admins = module{};
    projects = module{};
  };

in {
  inherit options;

  config = {
    systemd.services."hydra-autoproj" = {
      # todo: auto start after hydra
      serviceConfig = {
        WantedAfter = "hydra-init.service";
      };
    };
  };
}
