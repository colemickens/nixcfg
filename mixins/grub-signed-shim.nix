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
#  efiMount = "/boot/efi"; # see: https://github.com/NixOS/nixpkgs/issues/127727
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
          configurationLimit = 10;
          extraInstallCommands = let
            shim_path = {
              "x86_64-linux" = "\\EFI\\${efiBootloaderId}\\shimx64.efi";
              "aarch64-linux" = "\\EFI\\${efiBootloaderId}\\shima64.efi";
            }.${pkgs.system};
            # TODO: this is awkward because it runs on every rebuild instead of only when installing?
            # maybe we just check for NIXOS_INSTALL? maybe this is only running because we did the mod?
          in ''
            if true; then
              (
                export PATH="$PATH:${pkgs.efibootmgr}/bin"
                set -eu # don't enable pipefail, we need it off

                part=''$(mount | grep "${efiMount}" | cut -d ' ' -f 1)
                part=''${part#/dev/}
                disk=''$(readlink /sys/class/block/$part)
                disk=''${disk%/*}
                disk=/dev/''${disk##*/}

                shim_loader_name="${efiBootloaderId}-shim-''${part}";

                mkdir -p "${efiMount}/EFI/${efiBootloaderId}/"
                # TODO: remove "efi" when we get our efiMount right and nixos's grub does the right thing
                cp "${pkgs.shim-signed-fedora}/share/boot/efi/EFI/fedora"/* "${efiMount}/EFI/${efiBootloaderId}/"

                orig_entry=$(efibootmgr |grep '^Boot[0-9]' |grep " ${efiBootloaderId}$" |grep -Po '[0-9A-F]{4}\*' |sed 's/\*//g' |tr '\n' ',' |head -c -1)
                if [[ "$orig_entry" != "" ]] ; then
                  bootorder="$(efibootmgr -v | grep ^BootOrder | cut -d ' ' -f2)"
                  efibootmgr --bootnum $orig_entry --delete-bootnum >/dev/null
                  efibootmgr --create-only --bootnum $orig_entry --label "${efiBootloaderId}-shim" --loader "${shim_path}" --disk "$disk" >/dev/null
                  efibootmgr --bootorder "$bootorder" >/dev/null
                  efibootmgr
                fi
              )
            fi
          '';
        };
      };
    };
  };
}
