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
in
{
  imports = [
    inputs.h96.outputs.nixosModules.base-config
    inputs.h96.outputs.nixosModules.device-tree
    inputs.h96.outputs.nixosModules.mesa-24_2

    ../../profiles/core.nix
    ../../profiles/user-cole.nix

    ../../profiles/gui-sway-auto.nix

    ../../mixins/common.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/tailscale.nix
    ../../mixins/sshd.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

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
        mesa = inputs.h96.inputs.nixpkgs-mesa.outputs.legacyPackages.x86_64-linux.pkgsCross.aarch64-multiplatform.mesa;
      })
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
      picocom
      zellij
      pulsemixer
    ];

    hardware.graphics.enable = lib.mkForce false;

    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;

    nixcfg.common.useZfs = false;
    nixcfg.common.defaultKernel = false;
    nixcfg.common.wifiWorkaround = true;

    boot.loader.systemd-boot.enable = false;
    networking.wireless.enable = lib.mkForce false;
    networking.wireless.iwd.enable = true;

    networking.hostName = hn;
    system.stateVersion = "23.11";
  };
}
