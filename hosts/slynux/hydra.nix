{ config, pkgs, lib, inputs, modulesPath, ... }:

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
    # make sure we have hydra-queue-runner with ssh perms
    # this is ... icky (we need yubikey for hydra to work?)
    system.activationScripts.hydra-queue-runner = {
      text = ''
        mkdir -p /var/lib/hydra/queue-runner/.ssh
        cp --remove-destination /home/cole/.ssh/config /var/lib/hydra/queue-runner/.ssh/config
      '';
      deps = [];
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
