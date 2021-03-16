{ config, lib, pkgs, ... }:
let
  ver = "af47b17"; # branch (named "5.8.7.4") as of 2021-03-16
  sha = "sha256-Q2jJElKFMPRgHu/bitKpHZ7gsP3c0I4o0suFGoB2BLY=";

  pkg = pkgs.callPackage pkg_ { kernel = config.boot.kernelPackages.kernel; };
  pkg_ = (
    { stdenv, lib, fetchFromGitHub, kernel, kmod }:

    stdenv.mkDerivation rec {
      name = "88x2bu-${version}-${kernel.version}";
      version = ver;

      src = fetchFromGitHub {
        owner = "morrownr";
        repo = "88x2bu";
        rev = ver;
        sha256 = sha;
      };

      #sourceRoot = ".";
      hardeningDisable = [ "pic" "format" ];
      nativeBuildInputs = kernel.moduleBuildDependencies ++ (with pkgs; [
        bc
      ]);

      makeFlags = [
        "KERNELRELEASE=${kernel.modDirVersion}"
        "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "INSTALL_MOD_PATH=$(out)"
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
