{ inputs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        programs.gh = {
          enable = true;
          extensions = [
            pkgs.gh-actions-lock
          ];
        };
        home = {
          packages = with pkgs; [
            alejandra
            nil
            nixd
            nixfmt
            nixpkgs-review

            gh

            dfmt
            jless
            frogmouth

            mergiraf

            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
            inputs.autolith.packages.${pkgs.stdenv.hostPlatform.system}.default
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.copilot-cli
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cursor-agent
            # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh
            # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.goose-cli
            # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.maki
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mistral-vibe
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.muse-code
            # inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi

            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.tuicr

            inputs.chock.packages.${pkgs.stdenv.hostPlatform.system}.default

            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cli-proxy-api
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cliproxy-rs
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.magpie-cli

            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.mercat
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux

            worktrunk

            # mcp servers
            kraken-cli
            lunchmoney-mcp
          ];
          sessionVariables = {
            ENVRC_USE_FLAKE = 1;
          };
        };
      };
  };
}
