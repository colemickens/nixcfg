{ config, pkgs, lib, inputs, modulesPath, ... }:

let hydraAuto = pkgs.writeShellScript "hydra-auto.sh" ''
  
'';
in {
  config = {
    services.hydra-autoproj = {
      admins = {
        username = "cole";
        password = "cole";
        email = "cole@hydra";
      };
      projects = {
        "nixcfg" = {
          displayName = "nixcfg";
          decltype = "git";
          declvalue = "https://github.com/colemickens/nixcfg main";
          declfile = "spec.json";
        };
      };
    };
  };
}
