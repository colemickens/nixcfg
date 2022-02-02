{ config, pkgs, modulesPath, ... }:

# Note:
# 1. must package shim-signed
# 2. must fix grub to burn bootloaderId without mirroredBoot
# 3. must carefully activate:
#    - boot in non-secure-boot mode
#    - `sudo mokutil --disable-validation`
#    - boot in secure-boot mode
#    - inside the shim "Change Secure Boot mode"
#    - disable "Secure Boot" (this only disables validation in the shim itself)
#    - now you can reboot and the shim will boot through "in insecure mode"

let
  efiMount = "/boot";
in {
  config = {
    environment.systemPackages = with pkgs; [ mokutil ];
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = true; # okay, for now poke in the unsigned grub so we have *something* to boot
          efiSysMountPoint = efiMount;
        };
        grub = rec {
          enable = true;
          devices = [ "nodev" ];
          forceInstall = true;
          efiSupport = true;
          efiInstallAsRemovable = false;
          efiBootloaderId = "nixos-grub";
          configurationLimit = 5;
          extraInstallCommands = let
            shim_path = {
              "x86_64-linux" = "\\EFI\\${efiBootloaderId}\\shimx64.efi";
              "aarch64-linux" = "\\EFI\\${efiBootloaderId}\\shima64.efi";
            }.${pkgs.system};
          in ''
            if true; then
              (
                set -x
                set -eu # don't enable pipefail, we need it off

                # efibootmgr... come on: https://github.com/rhboot/efibootmgr/issues/159

                part=''$(mount | grep "${efiMount}" | cut -d ' ' -f 1)
                part=''${part#/dev/}
                disk=''$(readlink /sys/class/block/$part)
                disk=''${disk%/*}
                disk=/dev/''${disk##*/}

                shim_loader_name="nixos-grub-shim-''${part}";

                mkdir -p "/boot/EFI/${efiBootloaderId}/"
                cp "${pkgs.shim-signed-fedora}/share/boot/efi/EFI/fedora"/* "/boot/EFI/${efiBootloaderId}/"


                shim_entry=$(efibootmgr |grep '^Boot[0-9]' |grep "$shim_loader_name" |grep -Po '[0-9A-F]{4}\*' |sed 's/\*//g' |tr '\n' ',' |head -c -1)
                if [[ "$shim_entry" != "" ]] ; then
                  sudo efibootmgr --bootnum $shim_entry --delete-bootnum
                fi
                sudo efibootmgr --create --label "$shim_loader_name" --loader "${shim_path}" --disk "$disk"
                
                shim_entry=$(efibootmgr |grep '^Boot[0-9]' |grep "$shim_loader_name" |grep -Po '[0-9A-F]{4}\*' |sed 's/\*//g' |tr '\n' ',' |head -c -1)
                sudo efibootmgr --bootnext "$shim_entry"
              )
            fi
            echo "grub-shim: done"
          '';
        };
      };
    };
  };
}
