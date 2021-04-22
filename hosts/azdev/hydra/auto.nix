{ config, pkgs, lib, inputs, modulesPath, ... }:

{
  config = {
    services.hydra-autoproj = {
      admins = {
        username = "cole";
        password = "cole";
        email = "cole@hydra";
      };
      projects = {
        foo = {
          displayName = "friendlyFoo";
          # TODO: can this itself be a flake ref? I thought so?
          # enabled = "1"; # default
          # visible = "1"; # default
          # decltype = "git";
          # declvalue = "https://github.com/colemickens/nixcfg main";
          # declfile = "spec.json";
        };
      };
    };
  };
}
