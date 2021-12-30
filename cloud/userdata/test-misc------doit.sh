sudo kexec \
  --append="$(cat /proc/cmdline)" \
  --initrd="/run/booted-system/initrd" \
    /run/booted-system/kernel



sudo kexec \
  --append="$(cat /proc/cmdline)" \
  --dtb="/run/current-system/dtbs/broadcom/bcm2711-rpi-4-b.dtb" \
  --initrd="/run/booted-system/initrd" \
    /run/booted-system/kernel




oci os object put \
  --namespace "axobinpd5xwy" \
  --bucket-name "bucket-20211220-2306" \
  --name kernel \
  --file "/nix/store/xj4s8wl52p7nmdrnpy3d0jahi6bapcbf-nixos-system-nixos-22.05pre339470.d87b72206aa/kernel"

oci os object put \
  --namespace "axobinpd5xwy" \
  --bucket-name "bucket-20211220-2306" \
  --name initrd \
  --file "/nix/store/xj4s8wl52p7nmdrnpy3d0jahi6bapcbf-nixos-system-nixos-22.05pre339470.d87b72206aa/initrd"
