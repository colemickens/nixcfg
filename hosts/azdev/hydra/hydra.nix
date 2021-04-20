{ config, pkgs, lib, inputs, modulesPath, ... }:

# TODO: move this into a VM with stable nix
# and the storage array

# check storage array safe first
# ... ?

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
  config = {
    # ugh -- also, doesn't appear to even be related to why aarch64 is failing?
    #nix.package = lib.mkForce pkgs.nix;

    # hydra setup docs:
    # - create project:
    #   - git checkout (https://github.com/colemickens/nixcfg#main)
    #  - create jobset
    #    - legacy -> "hydra.nix" in "[input]"
    #      inputs -> "[input]" -> "https://git/cole/nixcfg main"

    sops.secrets."hydra_queue_runner_id_rsa" = {
      owner = "hydra-queue-runner";
      group = "hydra";
      mode = "0700";
      path = "/var/lib/hydra/queue-runner/.ssh/id_rsa";
    };
    sops.secrets."hydra_queue_runner_id_rsa.pub" = {
      owner = "hydra-queue-runner";
      group = "hydra";
      mode = "0700";
      path = "/var/lib/hydra/queue-runner/.ssh/id_rsa.pub";
    };

    services.hydra = {
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
