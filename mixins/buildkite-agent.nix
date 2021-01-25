{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  agentName = "${config.networking.hostName}";
in {
  config = {
    sops.secrets."buildkite-token" = {
      owner = "buildkite-agent-${agentName}";
      group = "buildkite-agent-${agentName}";
    };

    services.buildkite-agents."${agentName}" = {
      enable = true;
      tokenPath = config.sops.secrets."buildkite-token".path;
    };
  };
}