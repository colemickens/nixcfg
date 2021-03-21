#!/usr/bin/env bash

echo "remote-viewer unix+spice:///tmp/vmspice.socket"

set -x
qemu-system-x86_64 \
  -virtfs local,path=/run/media/cole,mount_tag=share,security_model=passthrough \
  -boot d -cdrom /tmp/iso \
  -m 9182 -enable-kvm \
  -audiodev pa,id=snd0,server=/run/user/1000/pulse/native \
  -device AC97,audiodev=snd0 \
  -vga qxl -device virtio-serial-pci -spice unix,addr=/tmp/vmspice.socket,disable-ticketing -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent

