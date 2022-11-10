{ stdenv, lib, buildPackages, fetchFromGitHub, perl, buildLinux, ... } @ args:

let
  modDirVersion = "5.10.66";
  tag = "c428536281d69aeb2b3480f65b2b227210b61535";
in
buildLinux (args // {
  version = "${modDirVersion}";
  inherit modDirVersion;

  src = fetchFromGitHub {
    owner = "radxa";
    repo = "kernel";
    rev = tag;
    hash = "sha256-xLnuSbgarpFhyvGGHuF1/NsHMMkSwTcaTs/c33XliuA=";
  };
  
  kernelPatches = [
    { patch = ./linux-rock5-patch.patch; }
  ];

  defconfig = "rockchip_linux_defconfig";

} // (args.argsOverride or {}))
