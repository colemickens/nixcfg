{ config, pkgs, lib, inputs, modulesPath, ... }:

let
  hydraHostname = "hydra.${config.networking.hostName}.ts.r10e.tech";
  aarch64_host_key="NDA5NiBTSEEyNTY6cFVEeDF1U3dBWHFYVm1IeDYzd3Q1aHZlYkRvQ1UrU01GYUoxeEI0SndyUSBhYXJjaDY0Lm5peG9zLmNvbW11bml0eSAoUlNBKQoyNTYgU0hBMjU2OmlQTlBGK3dkSmV6bjloejl0bjAyT05wd0FMZW10ZVR2cTVOejV4ZHNOYTggYWFyY2g2NC5uaXhvcy5jb21tdW5pdHkgKEVEMjU1MTkpCg==";
  machinesFile = pkgs.writeText "machines.txt" ''
    localhost x86_64-linux - 4 1 kvm,nixos-test,big-parallel,benchmark 
    colemickens@aarch64.nixos.community aarch64-linux - 4 1 kvm,nixos-test,big-parallel,benchmark - ${aarch64_host_key}
  '';
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
