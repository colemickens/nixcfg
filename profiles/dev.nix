{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = []
       ++ (with pkgs; [])
       ++ inputs.self.devShells.${pkgs.system}.devtools.nativeBuildInputs
      ;
    };
  };
}
