self: pkgs:
{
  # custom/newer packages
  gopass = pkgs.callPackage ./pkgs/gopass {};
  #ripasso = pkgs.callPackage ./pkgs/ripasso {};

  # system, mass rebuild:
  #libdrm = pkgs.callPackage ./pkgs/libdrm {};
  #mesa_glu = pkgs.callPackage ./pkgs/mesa-glu {
  #  inherit (pkgs.darwin.apple_sdk.frameworks) ApplicationServices;
  #};
  #mesa = pkgs.callPackage ./pkgs/mesa {
  #  llvmPackages = pkgs.llvmPackages_7;
  ##  inherit (pkgs.darwin.apple_sdk.frameworks) OpenGL;
  #  inherit (pkgs.darwin.apple_sdk.libs) Xplugin;  
  #};
}
