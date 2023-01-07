{ stdenv, lib, buildPackages, fetchFromGitLab, perl, buildLinux, ... } @ args:

let
  modDirVersion = "6.0.0";
  tag = "f2b8a788b81566c9c63f3daa17c9644183a8b86b";
in
buildLinux (args // {
  version = "${modDirVersion}";
  inherit modDirVersion;

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "JoshuaAshton";
    repo = "linux-hdr";
    rev = tag;
    hash = "sha256-LTUXxvSSNfJ/ioYfG/APknm4bNnYHen372qxPuRwFSM=";
  };

  structuredExtraConfig = with lib.kernel; {
    # RK_CONSOLE_THREAD = no;
  };

  kernelPatches = [
    # { patch = ./linux-rock5-patch.patch; }
  ] ++ (with buildPackages.kernelPatches; [
    bridge_stp_helper
    request_key_helper
  ]);

  # defconfig = "rockchip_linux_defconfig";

} // (args.argsOverride or { }))
