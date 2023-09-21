# https://github.com/illegalprime/nixos-on-arm/blob/7709513b41b0c1c50ed5b4e3b3644cd34b26652c/machines/raspberrypi-zero/otg.nix

{ config, lib, ... }:
let
  otg_modules = {
    "serial"       = { module = "g_serial"; config = "USB_G_SERIAL"; };
    "ether"        = { module = "g_ether"; config = "USB_ETH"; };
    "mass_storage" = { module = "g_mass_storage"; config = "USB_MASS_STORAGE"; };
    "midi"         = { module = "g_midi"; config = "USB_MIDI_GADGET"; };
    "audio"        = { module = "g_audio"; config = "USB_AUDIO"; };
    "hid"          = { module = "g_hid"; config = "USB_G_HID"; };
    "acm_ms"       = { module = "g_acm_ms"; config = "USB_G_ACM_MS"; };
    "cdc"          = { module = "g_cdc"; config = "USB_CDC_COMPOSITE"; };
    "webcam"       = { module = "g_webcam"; config = "USB_G_WEBCAM"; };
    "printer"      = { module = "g_printer"; config = "USB_G_PRINTER"; };
    "zero"         = { module = "g_zero"; config = "USB_ZERO"; };
    # "multi"        = { module = ""; config = ""; }; # TODO:
  };
in
with builtins;
with lib;
{
  options = {
    boot.otg = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          enable USB OTG, let your raspberry pi
          act as a USB device.
        '';
      };
      module = mkOption {
        type = types.enum (attrNames otg_modules);
        default = "zero";
        example = "ether";
        description = ''
          the OTG module to load
        '';
      };
      link = mkOption {
        type = types.enum ["module" "static"];
        default = "module";
        example = "static";
        description = ''
          to build the OTG kernel module statically in the kernel
          or as a dynamic module that can be loaded / unloaded
        '';
      };
    };
  };
  config = let
    module = otg_modules.${config.boot.otg.module};
    link = { "static" = "y"; "module" = "m"; }.${config.boot.otg.link};
  in mkIf config.boot.otg.enable {

    # add otg modules if necessary to kernel config
    boot.kernelPatches = [
      {
        name = "usb-otg";
        patch = null;
        extraConfig = ''
          USB_GADGET y
          USB_DWC2 m
          USB_DWC2_DUAL_ROLE y
          ${module.config} ${link}
        '';
      }
    ];

    # make sure they're loaded when the pi boots
    boot.kernelModules = [
      "dwc2" "${module.module}"
    ];

    boot.loader.raspberryPi.firmwareConfig = "dtoverlay=dwc2";
  };
}