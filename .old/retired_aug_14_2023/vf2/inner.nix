{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "vf2";
  pp = "vf2";
  static_ip = "192.168.70.40/16";
in
{
  imports = [
    ../../profiles/core.nix
    ../../mixins/iwd-networks.nix

    # this is rather interesting... if  do this "fix" then I don't
    # get the complaint about kernelPackages being set twice (which isn't really true anyway)
    # inputs.nixos-hardware.outputs.nixosModules.starfive-visionfive2
    "${inputs.nixos-hardware}/starfive/visionfive/v2/default.nix"
  ];

  config = {
    nixpkgs.hostPlatform.system = "riscv64-linux";
    system.stateVersion = "22.11";

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    networking.hostName = hn;
    hardware.deviceTree.name = "starfive/jh7110-starfive-visionfive-2-v1.2a.dtb";

    nix.nixPath = [ ];
    # nix.gc.automatic = true;

    nixcfg.common.defaultKernel = false;
    nixcfg.common.addLegacyboot = false;
    nixcfg.common.useZfs = false;

    systemd.network = {
      enable = true;
      # TODO TODO TODO
      networks."15-eth0-static-ip" = {
        matchConfig.Path = "platform-16030000.ethernet"; # end0
        # matchConfig.Path = "platform-16040000.ethernet"; # end1 (100mbit)
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DHCP = "no";
        };
      };
    };

    # environment.systemPackages = with pkgs; [
    #   binutils
    #   usbutils
    # ];

    networking.wireless.iwd.enable = true;

    boot = {
      # see: https://github.com/starfive-tech/linux/issues/101#issuecomment-1550787967
      blacklistedKernelModules = [ "clk-starfive-jh7110-vout" ];
      enableContainers = false;
      bootspec.enable = true;
      # lanzaboote = {
      #   enable = true;
      #   pkiBundle = "/etc/secureboot";
      #   configurationLimit = 4;
      # };
      loader = {
        efi.efiSysMountPoint = "/efi";
        grub.enable = false;
        # systemd-boot.enable = true;
        systemd-boot.enable = false;
        generic-extlinux-compatible.enable = lib.mkForce true;
        generic-extlinux-compatible.configurationLimit = 3;
      };

      tmp.useTmpfs = lib.mkForce false;
      # tmp.cleanOnBoot = false;

      # copied from: (https://github.com/NickCao/nixos-riscv/blob/55ec013f21dcf3da60f42b2d0c4f91c6183da2d8/visionfive2.nix#LL19C5-L19C79)
      # TODO: needed? upstream to nixos-hardware?
      initrd.kernelModules = [
        "motorcomm"
        "nvme"
        "nvme_core"
        "pcie_starfive"
        "phy_jh7110_pcie"
        "xhci_pci"
        "xhci_pci_renesas"
        "xhci_hcd"
        "dwmac-starfive"

        # pcie clocks for NVME (likely not all needed)
        "clk-starfive-jh71x0"
        "clk-starfive-jh7110-aon"
        "clk-starfive-jh7110-stg"
        "clk-starfive-jh7110-sys"
      ];
    };
  };
}
