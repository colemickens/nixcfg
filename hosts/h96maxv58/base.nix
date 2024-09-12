{ pkgs
, lib
, modulesPath
, inputs
, config
, extendModules
, ...
}:

let
  hn = "h96maxv58";
  ubootH96 = inputs.h96.outputs.packages.aarch64-linux.ubootH96MaxV58;
in
{
  imports = [
    # inputs.h96.outputs.nixosModules.base-config
    inputs.h96.outputs.nixosModules.kernel-config
    inputs.h96.outputs.nixosModules.device-tree

    ../../profiles/core.nix
    ../../profiles/user-cole.nix
    ../../profiles/user-jeff.nix

    # ../../profiles/gui-sway-auto.nix

    ../../mixins/common.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/unifi.nix

    inputs.disko.nixosModules.disko
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "armbian-firmware"
      "unifi-controller"
      "mongodb"
    ];

    disko.memSize = 4096; # TODO: fix make-disk-image.nix to output script that defaults to this, so annoying!!!!1111 or warn if used with impure!
    disko.extraPostVM = ''
      (
        set -x
        # TODO: GROSS TO HARDCODE, GROSSER THAT THE EXAMPLE WOULD CLOBBER HOME/*.RAW if it worked...
        disk=$out/disk0.raw
        ${pkgs.coreutils}/bin/dd if=${ubootH96}/u-boot-rockchip.bin of=$disk seek=64 bs=512 conv=notrunc
        ${pkgs.zstd}/bin/zstd --compress $disk
        rm $disk
      )
    '';
    disko.devices = {
      disk = {
        disk0 = {
          type = "disk";
          imageSize = "4G";
          content = {
            type = "gpt";
            partitions = {
              firmware = {
                start = "64";
                alignment = 1;
                end = "61440";
              };
              ESP = {
                start = "64M";
                end = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              rootfs = {
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };

    hardware.firmware = [
      (pkgs.armbian-firmware.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "armbian";
          repo = "firmware";
          rev = "6c1532bccd4f99608d7f09a0f115214a7867fb0a";
          hash = "sha256-DlRKCLOGW15FNfuzB/Ua2r1peMn/xHBuhOEv+e3VvTk=";
        };
        compressFirmware = false;
        installPhase = ''
                  runHook preInstall

                  mkdir -p $out/lib/firmware
                  cp -a * $out/lib/firmware/

          #        ln -sf $out/lib/firmware/ap6275p/fw_bcm43752a2_pcie_ag.bin $out/lib/firmware/brcm/brcmfmac43752-pcie.bin
          #        ln -sf $out/lib/firmware/ap6275p/fw_bcm43752a2_pcie_ag.bin $out/lib/firmware/brcm/brcmfmac43752-pcie.rockchip,rk3588.bin
          #        ln -sf $out/lib/firmware/ap6275p/clm_bcm43752a2_pcie_ag.blob $out/lib/firmware/brcm/brcmfmac43752-pcie.clm_blob
          #        ln -sf $out/lib/firmware/ap6275p/nvram_AP6275P.txt $out/lib/firmware/brcm/brcmfmac43752-pcie.txt
          #        ln -sf $out/lib/firmware/ap6275p/config.txt $out/lib/firmware/brcm/brcmfmac43752-pcie-more-config.txt

                  runHook postInstall
        '';
      })
    ];

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
      picocom
      zellij
      pulsemixer
      bottom
    ];

    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;

    nixcfg.common.useZfs = false;
    nixcfg.common.defaultKernel = false;
    nixcfg.common.wifiWorkaround = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.installDeviceTree = true;

    # add hardware device tree

    networking.wireless.enable = lib.mkForce false;
    networking.wireless.iwd.enable = true;

    networking.hostName = hn;
    system.stateVersion = "24.05";
  };
}
