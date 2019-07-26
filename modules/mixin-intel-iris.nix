{ pkgs, ... }:

{
  config = {
    # NOTE: we build iris in the overlay embedded in this repo now
    environment.variables = {
      MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };
  };
}
