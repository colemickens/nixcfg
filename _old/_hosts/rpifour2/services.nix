{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../mixins/buildkite-agent.nix
  ];

  config = {
    # services.buildVMs = {
    #   # `armv7-linux` builder that can run KVM'd on the aarch64 rpi4.
    #   # This is used to build packages for the Remarkable 2.
    #   "a64-native" = {
    #     system = "armv7l-linux";
    #     cpu = "host,aarch64=off"; ### ???? seems like probably for the arm7l ?
    #     buildSystem = "aarch64-linux";
    #     mem = "8g";
    #     smp = 8;
    #     crossSystem = null;
    #     kvm = true;
    #   };
    # };
  };
}
