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
    -spice port=6969,password=fuckme \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent

    -chardev socket,id=char9,path=/tmp/qemu-vhost \
    -device vhost-user-fs-pci,queue-size=1024,chardev=char9,tag=myfs

    true
elif [[ "${1}" == "xtails" ]]; then
  sudo rm -rf /tmp/vmspice-tails.socket
  sudo qemu-system-x86_64 \
    -nodefaults \
    -machine pc,accel=kvm \
    -cpu host \
    -smp 8 \
    -drive file=/dev/nvme0n1p5,if=virtio \
    -boot d -cdrom $ISO \
    -m 4096 \
    -enable-kvm \
    -monitor unix:qemu-monitor-socket,server,nowait \
    -m 4096 -object memory-backend-file,id=mem,size=4G,mem-path=/dev/shm,share=on -numa node,memdev=mem \
    -virtfs local,id=tmpvm,path=/tmp/vm,mount_tag=/tmp/vm,security_model=passthrough \
    -device intel-hda -device hda-duplex \
    -device virtio-serial \
    -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=3 \
    -vga none \
    -device virtio-gpu-pci,virgl=on \
    -spice gl=on,unix=on,addr=/tmp/vmspice-tails.socket,disable-ticketing=on \
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


