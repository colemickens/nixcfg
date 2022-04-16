{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    ../../modules/other-arch-vm.nix
  ];

  config = {
    services.buildVMs =
      let build_config = {
        imports = [
          ../../profiles/user.nix
        ];
      }; in
      {
        # "army" = {
        #   vmSystem = "armv6l-linux";
        #   crossSystem = pkgs.lib.systems.examples.raspberryPi;
        #   cpu = "arm1176";
        #   machine = "versatilepb";
        #   smp = 1;
        #   mem = "256M";
        #   sshListenPort = 2223;
        #   kvm = false;
        #   vmpkgs = inputs.nixpkgs;
        #   config = build_config;
        #   autostart = false;
        # };
        # "rusky" = {
        #   vmSystem = "riscv64-linux";
        #   crossSystem = pkgs.lib.systems.examples.riscv64;
        #   smp = 4;
        #   mem = "8G";
        #   sshListenPort = 2222;
        #   kvm = false;
        #   vmpkgs = inputs.riscvpkgs;
        #   config = build_config;
        # };
      };
  };
}
