{
  description = "A very basic flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.test_bug1 = nixpkgs.lib.nixosSystem {
      # bug1: system inf recurses when trying to build mangohud32
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          # bug1:
          nixpkgs.hostPlatform.system = "x86_64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux";

          fileSystems = {
            "/" = {
              fsType = "ext4";
              device = "/dev/sda";
            };
          };
          boot.loader.grub.enable = false;
          boot.loader.systemd-boot.enable = true;
          environment.systemPackages = with pkgs; [
            mangohud
          ];
        })
      ];
    };
    # bug2: invalid
    # nixosConfigurations.test_bug2 = nixpkgs.lib.nixosSystem {
    #   # bug2: nushell fails to cross compile
    #   system = "x86_64-linux";
    #   modules = [
    #     ({ pkgs, ... }: {
    #       nixpkgs.hostPlatform.system = "aarch64-linux";
    #       nixpkgs.buildPlatform.system = "x86_64-linux";

    #       fileSystems = {
    #         "/" = {
    #           fsType = "ext4";
    #           device = "/dev/sda";
    #         };
    #       };
    #       boot.loader.grub.enable = false;
    #       boot.loader.systemd-boot.enable = true;
    #       environment.systemPackages = with pkgs; [
    #         nushell
    #       ];
    #     })
    #   ];
    # };
    packages.x86_64-linux.test_bug3 = nixpkgs.legacyPackages.x86_64-linux.pkgsCross.aarch_64-linux.nushell;

    nixosConfigurations.test_bug3 = nixpkgs.lib.nixosSystem {
      # system = "aarch64-linux";
      modules = [
        ({ pkgs, ... }: {
          # bug1:
          # nixpkgs.hostPlatform.system = "x86_64-linux";

          system.stateVersion = "23.11";
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux";

          fileSystems = {
            "/" = {
              fsType = "ext4";
              device = "/dev/sda";
            };
          };
          boot.loader.grub.enable = false;
          boot.loader.systemd-boot.enable = true;
          environment.systemPackages = with pkgs; [
            # bug1:
            # nushell
            # mangohud
            # nushell
          ];
        })
      ];
    };
  };
}
