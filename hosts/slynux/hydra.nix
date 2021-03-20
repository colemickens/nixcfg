{ config, pkgs, lib, inputs, modulesPath, ... }:

{
  config = {
    nix.buildMachines = [
      { hostName = "localhost";
        system = "x86_64-linux";
        systems = [ "x86_64-linux" ];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 4;
      }
      { hostName = "aarch64.nixos.community";
        sshUser = "colemickens";
        system = "aarch64-linux";
        systems = [ "aarch64-linux" ];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
        maxJobs = 4;
      }
    ];

    #nix.package = lib.mkForce pkgs.nix;

    services.hydra = {
      enable = true;
      hydraURL = "http://hydra.${config.networking.hostName}.ts.r10e.tech"; # externally visible URL
      notificationSender = "hydra@localhost"; # e-mail of hydra service
      # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
      buildMachinesFiles = [];
      # you will probably also want, otherwise *everything* will be built from scratch
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
