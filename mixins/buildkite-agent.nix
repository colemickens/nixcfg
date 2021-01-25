{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  agentName = "${config.networking.hostName}";
in {
  config = {
    sops.secrets."buildkite-agent" = {
      owner = "buildkite-agent-${agentName}";
      group = "buildkite-agent-${agentName}";
    };

    services.buildkite-agents."${agentName}" = {
      enable = true;
      tokenPath = sops.secrets."buildkite-agent".path;
    };
  };
}