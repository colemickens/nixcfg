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
    # TODO:
    # 1. don't want to actually use aarch64 box for this
    # 2. I think there's version skew issues regarding using
    #    nixUnstable with hydra and aarch64.nixos using nixStable
    { #hostName = "aarch64.nixos.community";
      #sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1VVHo1aTl1NUgyRkhOQW1aSnlvSmZJR3lVbS9IZkdoZnduYzE0MkwzZHMK";
      #sshUser = "colemickens";

      hostName = "rpifour1.ts.r10e.tech";
      sshUser = "cole";
      # ❯ echo "rpifour1.ts.r10e.tech ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOocMaAv2g1YK6SBFUYl4azZ0dGRid07D9CN8TQ2CCAa" | base64 -w0
      sshHostKeyBase64 = "cnBpZm91cjEudHMucjEwZS50ZWNoIHNzaC1lZDI1NTE5IEFBQUFDM056YUMxbFpESTFOVEU1QUFBQUlPb2NNYUF2MmcxWUs2U0JGVVlsNGF6WjBkR1JpZDA3RDlDTjhUUTJDQ0FhCg==";

      # ❯ echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOocMaAv2g1YK6SBFUYl4azZ0dGRid07D9CN8TQ2CCAa" | base64 -w0
      #sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9vY01hQXYyZzFZSzZTQkZVWWw0YXpaMGRHUmlkMDdEOUNOOFRRMkNDQWEK";
      #sshKey = # it's just in the /var/lib/hydra/queue-runner/.ssh/id_rsa
      system = "aarch64-linux";
      systems = [ "aarch64-linux" ];
      mandatoryFeatures = [];
      supportedFeatures = ["kvm" "nixos-test" "benchmark"];
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
