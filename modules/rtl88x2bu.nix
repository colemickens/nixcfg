{ config, lib, pkgs, ... }:
let
  pkg = pkgs.callPackage pkg_ { kernel = config.boot.kernelPackages.kernel; };
  pkg_ = (
    { stdenv, lib, fetchFromGitHub, kernel, kmod }:

    stdenv.mkDerivation rec {
      name = "88x2bu-${version}-${kernel.version}";
      version = "5.8.7.4";

      src = fetchFromGitHub {
        owner = "morrownr";
        repo = "88x2bu";
        rev = "v${version}";
        sha256 = "1d9qpnmqa3pfwsrpjnxdz76ipk4w37bbxyrazchh4vslnfc88666";
      };

      sourceRoot = ".";
      hardeningDisable = [ "pic" "format" ];                                             # 1
      nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2

      makeFlags = [
        "KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
        "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
        "INSTALL_MOD_PATH=$(out)"                                               # 5
      ];

      meta = with lib; {
        description = "";
        homepage = "";
        license = licenses.gpl2;
        platforms = platforms.linux;
      };
    }
  );
in
{
  config = {
    boot.extraModulePackages = [
      pkg
    ];
    boot.kernelModules = [ "88x2bu" ];
  };
}
