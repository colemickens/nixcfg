{ config, pkgs, inputs, ... }@args:

let
  host_color = config.nixcfg.common.hostColor;
  _nu = n: (pkgs.substituteAll {
    name = "nushell-${n}-subbed.nu";
    src = ./nushell-${n}.nu;
    inherit host_color;
  }).outPath;
  env_nu = _nu "env";
  config_nu = _nu "config";
  prompt_nu = _nu "prompt";
in
{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        nushell = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nushell;
      })
    ];
    home-manager.users.cole = { pkgs, ... }@hm:
      let
        configDir = "${hm.config.xdg.configHome}/nushell";
      in
      {
        home.file."${configDir}/env.nu".source = env_nu;
        home.file."${configDir}/config.nu".source = config_nu;

        home.file."${configDir}/prompt.nu".source = prompt_nu;

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
