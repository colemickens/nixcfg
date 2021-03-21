{ config, pkgs, lib, inputs, modulesPath, ... }:

# TODO: move this into a VM with stable nix
# and the storage array

# check storage array safe first
# ... ?

let
  hydraHostname = "hydra.${config.networking.hostName}.ts.r10e.tech";
  machinesConfig = [
    {
      hostName = "localhost";
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
    # { 
    #   hostName = "aarch64.nixos.community";
    #   sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1VVHo1aTl1NUgyRkhOQW1aSnlvSmZJR3lVbS9IZkdoZnduYzE0MkwzZHMK";
    #   sshUser = "colemickens";
    #   #sshKey = # it's just in the /var/lib/hydra/queue-runner/.ssh/id_rsa
    #   system = "aarch64-linux";
    #   systems = [ "aarch64-linux" ];
    #   mandatoryFeatures = [];
    #   supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
    #   speedFactor = 1;
    #   maxJobs = 4;
    # }
    {
      hostName = "rpifour1.ts.r10e.tech";
      sshUser = "cole";
      # ❯ echo "rpifour1.ts.r10e.tech ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOocMaAv2g1YK6SBFUYl4azZ0dGRid07D9CN8TQ2CCAa" | base64 -w0
      #sshHostKeyBase64 = "cnBpZm91cjEudHMucjEwZS50ZWNoIHNzaC1lZDI1NTE5IEFBQUFDM056YUMxbFpESTFOVEU1QUFBQUlPb2NNYUF2MmcxWUs2U0JGVVlsNGF6WjBkR1JpZDA3RDlDTjhUUTJDQ0FhCg==";
      # ❯ echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOocMaAv2g1YK6SBFUYl4azZ0dGRid07D9CN8TQ2CCAa" | base64 -w0
      sshHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9vY01hQXYyZzFZSzZTQkZVWWw0YXpaMGRHUmlkMDdEOUNOOFRRMkNDQWEK";
      #❯ echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZCBn0BJ1Aun4zfJ6Tb7eM7ORp/zQl60nAdDeaSCoiGuHgFiR3Mz0u6vxrK+y7628e5sqRMUqExoQFmnkd/uuAUnjFPHb8n1e+2B0qM3fBD9qAOCvXxEdpikmbQUySohbkYt9bVK8wV1tPeb4+LApwpGmK1cNYNRZb+6R4cxuunOU2jivUTTa/KasXoRkrmSgOHlSvchyh5/Qnnbxt4ENXjXWom30RdKReyh46GgimJVG8LlX+3JJknmh9/jkffwrFPsVRSKdAome8xWaOCngo2obDdSOtl4npasZBdkZ7dbiLRZ0aFBGsPBoNOW5mJR7beaczzOlmgUiNxosn8/+bn/8FjI1KdhvNIU/jHMH2Eh/vDGZtpKo0kV8nzBBsCncdTrfzPZpx4dotD5oAUdLsViIX+BG+cAC9aze1PBwFiFwTxIamWSlH9ah+31CcCPdjQPzIU6l4pgeq6AnjK4q7UaJb/jWqDPdOufqUxOqJniLNY/XtG9L8APCh+m4RElLTHtklbd2xgrrpqP9IfVqIjitq7b30fQo3YLA2SJ10BW22LX1DSBnYt0yzoPtyQtKvNuZnMEL5vQmrg/rc8cKvOFyVf5OyF0/wKw3Fq5MHFtRTFDxVuTp8hRily5vi2yXh8K83AmklOK+30uRTLICSOTTEXEg8fiY611Ohal+mjw==" | base64 -w0
      #sshHostKeyBase64 = "c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFEWkNCbjBCSjFBdW40emZKNlRiN2VNN09ScC96UWw2MG5BZERlYVNDb2lHdUhnRmlSM016MHU2dnhySyt5NzYyOGU1c3FSTVVxRXhvUUZtbmtkL3V1QVVuakZQSGI4bjFlKzJCMHFNM2ZCRDlxQU9Ddlh4RWRwaWttYlFVeVNvaGJrWXQ5YlZLOHdWMXRQZWI0K0xBcHdwR21LMWNOWU5SWmIrNlI0Y3h1dW5PVTJqaXZVVFRhL0thc1hvUmtybVNnT0hsU3ZjaHloNS9Rbm5ieHQ0RU5YalhXb20zMFJkS1JleWg0NkdnaW1KVkc4TGxYKzNKSmtubWg5L2prZmZ3ckZQc1ZSU0tkQW9tZTh4V2FPQ25nbzJvYkRkU090bDRucGFzWkJka1o3ZGJpTFJaMGFGQkdzUEJvTk9XNW1KUjdiZWFjenpPbG1nVWlOeG9zbjgvK2JuLzhGakkxS2Rodk5JVS9qSE1IMkVoL3ZER1p0cEtvMGtWOG56QkJzQ25jZFRyZnpQWnB4NGRvdEQ1b0FVZExzVmlJWCtCRytjQUM5YXplMVBCd0ZpRndUeElhbVdTbEg5YWgrMzFDY0NQZGpRUHpJVTZsNHBnZXE2QW5qSzRxN1VhSmIvaldxRFBkT3VmcVV4T3FKbmlMTlkvWHRHOUw4QVBDaCttNFJFbExUSHRrbGJkMnhncnJwcVA5SWZWcUlqaXRxN2IzMGZRbzNZTEEyU0oxMEJXMjJMWDFEU0JuWXQweXpvUHR5UXRLdk51Wm5NRUw1dlFtcmcvcmM4Y0t2T0Z5VmY1T3lGMC93S3czRnE1TUhGdFJURkR4VnVUcDhoUmlseTV2aTJ5WGg4SzgzQW1rbE9LKzMwdVJUTElDU09UVEVYRWc4ZmlZNjExT2hhbCttanc9PQo=";
      system = "aarch64-linux";
      systems = [ "aarch64-linux" ];
      mandatoryFeatures = [];
      supportedFeatures = [];
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
