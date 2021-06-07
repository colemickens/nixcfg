#!/usr/bin/env bash

echo "remote-viewer spice+unix:///tmp/vmspice.socket"

#  -virtfs local,path=/run/media/cole,mount_tag=share,security_model=passthrough \

set -x
set -eu

if [[ "${1}" == "tails" ]]; then
  sudo rm -rf /tmp/vmspice-tails.socket
  sudo qemu-system-x86_64 \
    -drive file=/dev/nvme0n1p5,if=virtio \
    -boot d -cdrom $ISO \
    -m 4096 \
    -enable-kvm \
    -virtfs local,id=tmpvm,path=/tmp/vm,mount_tag=/tmp/vm,security_model=passthrough \
    -audiodev pa,id=snd0,server=/run/user/1000/pulse/native \
    -device AC97,audiodev=snd0 \
    -vga qxl -device virtio-serial-pci \
    -spice unix=on,addr=/tmp/vmspice-tails.socket,disable-ticketing=on \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent
elif [[ "${1}" == "smb" ]]; then
  sudo rm -rf /tmp/vmspice-tails.socket
  sudo qemu-system-x86_64 \
    -drive file=/dev/nvme0n1p5,if=virtio \
    -boot d -cdrom $ISO \
    -m 4096 \
    -enable-kvm \
    -virtfs local,id=tmpvm,path=/tmp/vm,mount_tag=/tmp/vm,security_model=passthrough \
    -audiodev pa,id=snd0,server=/run/user/1000/pulse/native \
    -device AC97,audiodev=snd0 \
    -vga qxl -device virtio-serial-pci \
    -spice unix=on,addr=/tmp/vmspice-tails.socket,disable-ticketing=on \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent
elif [[ "${VM}" == "win" ]]; then
  sudo rm -rf /tmp/vmspice-win.socket
  sudo qemu-system-x86_64 \
    -drive file=/dev/nvme0n1p5,if=virtio \
    -boot d -cdrom $ISO \
    -m 4096 \
    -enable-kvm \
    -virtfs local,id=tmpvm,path=/tmp/vm,mount_tag=/tmp/vm,security_model=passthrough \
    -audiodev pa,id=snd0,server=/run/user/1000/pulse/native \
    -device AC97,audiodev=snd0 \
    -vga qxl -device virtio-serial-pci \
    -spice unix=on,addr=/tmp/vmspice-win.socket,disable-ticketing=on \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent
fi


