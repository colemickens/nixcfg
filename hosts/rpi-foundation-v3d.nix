{ pkgs, lib, modulesPath, inputs, config, ... }:

## RPI-FOUNDATION V3D ENABLEMENT

{
  config = {
    hardware.deviceTree = {
      filter = "bcm*rpi*dtb";
      overlays = [
        {
          name = "audio-on-overlay";
          dtsText = ''
            /dts-v1/;
            /plugin/;
            / {
              compatible = "brcm,bcm2711";
              fragment@0 {
                target = <&audio>;
                __overlay__ {
                  status = "okay";
                };
              };
            };
          '';
        }
        # Equivalent to:
        # https://github.com/raspberrypi/linux/blob/rpi-5.10.y/arch/arm/boot/dts/overlays/vc4-fkms-v3d-overlay.dts
        {
          name = "rpi4-vc4-fkms-v3d-overlay";
          dtsText = ''
            // SPDX-License-Identifier: GPL-2.0
            /dts-v1/;
            /plugin/;
            / {
              compatible = "brcm,bcm2711";
              fragment@1 {
                target = <&fb>;
                __overlay__ {
                  status = "disabled";
                };
              };
              fragment@2 {
                target = <&firmwarekms>;
                __overlay__ {
                  status = "okay";
                };
              };
              fragment@3 {
                target = <&v3d>;
                __overlay__ {
                  status = "okay";
                };
              };
              fragment@4 {
                target = <&vc4>;
                __overlay__ {
                  status = "okay";
                };
              };
            };
          '';
        }
      ];
    };
  };
}
