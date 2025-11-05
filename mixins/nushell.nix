{ config, pkgs, ... }:

let
  host_color = config.nixcfg.common.hostColor;
  _nu =
    n:
    (pkgs.substitute {
      name = "nushell-${n}-subbed.nu";
      src = ./nushell-${n}.nu;
      substitutions = [
        "--replace"
        "@host_color@"
        host_color
      ];
    }).outPath;
  config_nu = _nu "config";
in
{
  config = {
    # nixpkgs.overlays = [
    #   (final: prev: { nushell = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nushell; })
    # ];
    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        programs.nushell.configFile.source = config_nu;

        programs.nushell = {
          enable = true;
          # envFile = env_nu;
          # configFile = config_nu;
          # envFile.source = env_nu;
          # configFile.source = config_nu;
        };
      };
  };
}
