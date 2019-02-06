{ config, lib, pkgs, ... }:

# TODO: this doesn't work

{
  config = {
    environment.etc."libinput/local-overrides.quirks".text = ''
      [Touchpad touch override]
      MatchUdevType=touchpad
      MatchName=*Magic Trackpad 2
      AttrPressureRange=4:0
    '';
  };
}

