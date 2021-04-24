{ config, pkgs, lib, inputs, modulesPath, ... }:

# hydra setup docs:
# - create project:
#   - git checkout ("https://github.com/colemickens/nixcfg main")
#  - add jobset
#    - legacy -> "hydra.nix" in "[input]"
#      inputs -> "[input]" -> "https://github.com/colemickens/nixcfg main"

# make sure aarch64 has our key (it should be added permanently now, though):
#   sudo ssh-copy-id -i /run/secrets/hydra_queue_runner_id_rsa colemickens@aarch64.nixos.community

let
  hydraHostname = "hydra.${config.networking.hostName}.ts.r10e.tech";
  hydraMachines = import ./hydra-machines.nix;
  machinesConfig = with hydraMachines; [
    localhost
    a64community
    #rpifour1
  ];
  builder = (import ./hydra-machine-txt-builder.nix { inherit lib; });
  machinesFileText = (builder machinesConfig);
  machinesFile = pkgs.writeText "machines.txt" machinesFileText;
in {
  # this pull in the entire hydra overlay:
  imports = [
    inputs.hydra.nixosModules.hydra
    ./auto.nix
  ];

  config = {
    sops.secrets."hydra_queue_runner_id_rsa" = {
      owner = "hydra-queue-runner";
      group = "hydra";
    };
    sops.secrets."hydra_queue_runner_id_rsa.pub" = {
      owner = "hydra-queue-runner";
      group = "hydra";
    };
    users.users."hydra-queue-runner".extraGroups = [ "keys" ];

    services.hydra-dev = {
      enable = true;
      hydraURL = "http://${hydraHostname}"; # externally visible URL
      notificationSender = "hydra@${hydraHostname}";
      buildMachinesFiles = lib.mkForce [
        machinesFile
      ];
      useSubstitutes = true;
      package = pkgs.hydra-unstable.overrideAttrs(old: {
      prePatch = ''
        sed -i 's/evalSettings.restrictEval = true/evalSettings.restrictEval = false/' "$(find -name hydra-eval-jobs.cc)"
      '' + (old.prePatch or ''
      '');
      });
    };

    services.nginx.virtualHosts."hydra.${config.networking.hostName}.ts.r10e.tech" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:3000/";
          proxyWebsockets = true;
        };
      };
    };
  };
}
