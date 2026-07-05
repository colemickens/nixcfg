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

            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.nanocoder
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent
          ];
          sessionVariables = {
            ENVRC_USE_FLAKE = 1;
          };
        };
      };
  };
}
