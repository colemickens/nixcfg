{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        inputs.marksman.outputs.packages.${pkgs.system}.default
        rnix-lsp
      ];
    };
  };
}
