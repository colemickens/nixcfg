{ inputs, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        home = {
          packages = with pkgs; [
            alejandra
            nil
            nixd
            nixfmt
            nixpkgs-review

            dfmt

            mergiraf

            radicle-node

            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.copilot-cli
            
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.goose-cli
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.nanocoder
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
            kraken-cli
          ];
          sessionVariables = {
            ENVRC_USE_FLAKE = 1;
          };
        };
      };
  };
}
