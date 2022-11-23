{ pkgs, lib, config, inputs, ... }:

{
  config = {
    nix.gc.automatic = lib.mkForce false;
    
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = []
       ++ (with pkgs; [])
       ++ inputs.self.devShells.${pkgs.hostPlatform.system}.devtools.nativeBuildInputs
      ;
    };
  };
}
