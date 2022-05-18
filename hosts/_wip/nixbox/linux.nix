{ config, pkgs, lib, ... }:

let
  linux26_xbox = {};
  linux_xbox = { fetchFromGitHub, buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "5.4.0-rc3";
      modDirVersion = version;

      src = fetchFromGitHub {
        owner = "XboxDev";
        repo = "xbox-linux";
        rev = "cc89bd62acde4130b24854711db18c6513678484"; #xbox-linux at March 21 2021
        sha256 = "sha256-nfAbnPiYdVVvx0WSWcZWwKfqqLMWelydJj2FLEhjIzU=";
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