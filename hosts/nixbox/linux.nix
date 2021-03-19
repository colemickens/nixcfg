{ config, pkgs, lib, ... }:

let
  linux26_xbox = {};
  linux_xbox = { fetchurl, buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "5.4.0-rc3";
      modDirVersion = version;

      src = fetchurl {
        url = "https://github.com/jsakkine-intel/linux-sgx/archive/v23.tar.gz";
        sha256 = "11rwlwv7s071ia889dk1dgrxprxiwgi7djhg47vi56dj81jgib20";
      };
      kernelPatches = [];

      extraConfig = ''
        INTEL_SGX y
      '';

      extraMeta.branch = "5.4";
    } // (args.argsOverride or {}));
in
  pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_sgx);
in {
  # make-disk-image
  # not-os
  # linux_xbox for kernelPackages

  # produces a script that will boot xemu and then the thing
  src = {};
  config = {
    boot.kernelPackages = xboxKernelPackages;
  };
}