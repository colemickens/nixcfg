{ pkgs, ... }:

let
  mesa_HEAD = pkgs.callPackage ../pkgs/mesa {
    llvmPackages = pkgs.llvmPackages_7;
    inherit (pkgs.darwin.apple_sdk.frameworks) OpenGL;
    inherit (pkgs.darwin.apple_sdk.libs) Xplugin;
  };
  #mesa_ = mesa_HEAD;
  mesa_ = pkgs.mesa;
in
{
  config = {
    environment.variables = {
      MESA_LOADER_DRIVER_OVERRIDE = "iris";
    };
    hardware.opengl.package = (mesa_.override {
      galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
    }).drivers;
  };
}
