{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hn = "rpizero2";

  rpiz2 = inputs.self.nixosConfigurations.rpizerotwo2;
  build = rpiz2.config.system.build.towbootBuild;
  pl = build.config.Tow-Boot.outputs.diskImage;
in
{
  imports = [
    ../rpizero1/configuration.nix
  ];

  config = {
    networking.hostName = lib.mkForce hn;
  };
}
