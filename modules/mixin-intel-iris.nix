{ pkgs, ... }:

{
  config = {
    # we're using the overlay for now:
    hardware.opengl.package =
      (pkgs.mesa.override {
        galliumDrivers = [ "virgl" "svga" "swrast" "iris" ];
        driDrivers = [ "i915" "i965" ];
        vulkanDrivers = [ "intel" ];
      }).drivers;

    environment.variables = {
      MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };
  };
}
