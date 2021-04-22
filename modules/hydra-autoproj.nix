# module to auto-populate hydra projects based on flake->hydraSpecs
{ config, lib, pkgs }:

# TODO: This is like 30% half-fleshed out, never run/tested, etc, needs a lot of love (or for hydra to be replaced)

let
  adminScript = email: username: password:  pkgs.writeShellScript "hydra-autoproj.sh" ''
    sudo -u hydra -- ${pkgs.hydra-dev}/bin/hydra-create-user "${username}" --full-name "${username}" --email-address "${email}" --password "${password}" --role admin
  '';

  # { 
  #   "admin" = { password = "admin"; role = "admin"; };
  #   "viewer" = { password = "viewer"; };
  # }

  newProject = {
    displayName,
    visible ? true,
    decltype ? "git",
    declvalue ? "",
    declfile ? "spec.json",
  }@args: toJSON args; # TODO: escape it?

  projectScript = projectName: p: pkgs.writeShellScript "hydra-autoproj.sh" ''
    LOGIN="{\"username\":\"cole\", \"password\": \"cole\"}"
    ${pkgs.curl}/bin/curl -b /tmp/cookie -c /tmp/cookie -d "${LOGIN}" -X 'POST' -H 'Content-Type: application/json' --referer 'http://localhost:3000/' http://localhost:3000/login

    JSON="${newProject p}"
    ${pkgs.curl}/bin/curl -b /tmp/cookie -c /tmp/cookie -d "${JSON}" -X 'PUT' -H 'Content-Type: application/json' --referer 'http://localhost:3000/' http://localhost:3000/project/${projectName}
  '';

  options = {
    # option for autoAdmin
    # option for autoProjects
    # option for the endpoint
  };

  config = {
    systemd.services."hydra-autoproj" = {
      # todo: auto start after hydra
    };
  };
in
{ inherit options config; }
