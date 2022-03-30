b=/run/booted-system
sudo kexec -l \
  "${b}/kernel" \
  --dtb "/sys/firmware/fdt" \
  --initrd "${b}/initrd" \
  --append "$(cat ${b}/kernel-params)"

sudo systemctl kexec

# notes:
# kexec forwards /proc/device-tree:
# - https://github.com/antonblanchard/kexec-lite/issues/15#issue-730020084
# - except not:
#  -- https://lwn.net/Articles/637591/

# still doesn't work though,
# even with ARM-TF and even without
# extlinux providing dtb (so passthru)
