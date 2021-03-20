{ config, pkgs, lib, inputs, modulesPath, ... }:

# TODO: move this into a VM with stable nix
# and the storage array

# check storage array safe first
# ... ?

let
  hydraHostname = "hydra.${config.networking.hostName}.ts.r10e.tech";
  machinesConfig = [
    { hostName = "localhost";
      system = "x86_64-linux";
      systems = [ "x86_64-linux" "i686-linux" ];
      mandatoryFeatures = [];
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      speedFactor = 1;
      maxJobs = 4;
    }
    { hostName = "aarch64.nixos.community";
      sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1VVHo1aTl1NUgyRkhOQW1aSnlvSmZJR3lVbS9IZkdoZnduYzE0MkwzZHMK";
      sshUser = "colemickens";
      #sshKey = # it's just in the /var/lib/hydra/queue-runner/.ssh/id_rsa
      system = "aarch64-linux";
      systems = [ "aarch64-linux" ];
      mandatoryFeatures = [];
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      speedFactor = 1;
      maxJobs = 4;
    }
  ];
  builder = (import ./hydra-machinestxt-builder.nix { inherit lib; });
  machinesFileText = (builder machinesConfig);
  machinesFile = pkgs.writeText "machines.txt" machinesFileText;
in {
  config = {
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
