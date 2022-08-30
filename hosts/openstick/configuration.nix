{ pkgs, lib, inputs, config, ... }:

let
  hostname = "openstick";
in
{
  imports = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "openstick";
    })
  ];

  config = {
    # system.build.mobile = confic`mobile.outputs.android.abootimg;

    system.stateVersion = "21.05";
  };
}
