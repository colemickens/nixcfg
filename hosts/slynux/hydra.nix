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
    #a64community
    rpifour1
  ];
  builder = (import ./hydra-machinestxt-builder.nix { inherit lib; });
  machinesFileText = (builder machinesConfig);
  machinesFile = pkgs.writeText "machines.txt" machinesFileText;
in {
  config = {
    # ugh
    nix.package = lib.mkForce pkgs.nix;

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
        '' + (old.prePatch or "");
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
