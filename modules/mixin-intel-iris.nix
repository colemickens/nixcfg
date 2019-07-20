{ pkgs, ... }:

{
  config = {
    environment.variables = {
      MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };
    hardware.opengl.package = (pkgs.mesa.override {
      galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
    }).drivers;
  };
}
