{ config, pkgs, lib, ... }:

{
  config = {
    boot = {
      kernelModules = [ "amd-pstate" ];
      blacklistedKernelModules = [ "acpi-cpufreq" ];
    };
  };
}
