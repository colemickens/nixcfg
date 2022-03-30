{ pkgs, lib, config, inputs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      radeontop
    ];
    hardware.graphics.enable = true;
    # no driver is needed, amdgpu is in mesa
    hardware.opengl.extraPackages = [ pkgs.amdvlk ];
  };
}
