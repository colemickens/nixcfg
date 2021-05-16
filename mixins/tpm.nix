{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  agentName = "${config.networking.hostName}";
in {
  config = {
    security.tpm2 = {
      enable = true;
      applyUdevRules = true;
      tctiEnvironment.enable = true;
    };
  };
}
