{ config, pkgs, lib, modulesPath, ... }:

let
  hostname = "rpitwo";
  rpitwo_tftp_dir = pkgs.runCommandNoCC "build-tftp-rpitwo" {} ''
    set -x

    mkdir $out
    
    # TODO: copy, apply cfg for the eeprom pieeprom.upd/sig
    # cp -a ${pkgs.raspberrypi-eeprom.src}/lib/firmware/raspberry/* $out/
    # sha256sum .. > ..
    
    cp -a "${pkgs.raspberrypifw}/share/raspberrypi/boot/" $out/
  '';

  uefi_dir = pkgs.runCommandNoCC "build-uefi" {} ''
    set -x
    mkdir $out    
    cp -a "${pkgs.rpi4-uefi-fw}/boot" $out/
  '';
  
  nixos = import "${modulesPath}/../lib/eval-config.nix" {
    modules = [ (import ../rasptwo/configuration.nix) ];
    system = "aarch64-linux";
  };
  build = nixos.config.system.build;
in
{
  config = {
    services.atftpd = {
      enable = true;
      root = "${uefi_dir}/boot";
    };
    networking.firewall.allowedUDPPorts = [ 67 69 4011 ];
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
