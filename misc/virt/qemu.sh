#!/usr/bin/env bash
set -x
set -eu
args=()

OVMF="$(nix eval --raw '../..#pkgs.x86_64-linux.OVMF.fd')/FV/OVMF.fd"
#OVMF="/nix/store/7ggn9i4w6kfhgsb3acc0xw5wqhh5dk95-OVMF-202108-fd/FV/OVMF.fd"

# echo "remote-viewer spice+unix:///tmp/vmspice.socket"
#  -virtfs local,path=/run/media/cole,mount_tag=share,security_model=passthrough \
sudo rm -rf /tmp/qemu.socket

source ../../secrets/unencrypted/qemu-profile-$1

[[ "${QEMU_VIRTIO_GPU:-""}" == "gl" ]]   && args=("${args[@]}"
  -vga none
  -device virtio-gpu-pci,virgl=on
  -spice gl=on,unix=on,addr=/tmp/qemu.socket,disable-ticketing=on)
[[ "${QEMU_VIRTIO_GPU:-""}" == "win" ]]   && args=("${args[@]}"
  -vga qxl
  # -spice unix=on,addr=/tmp/qemu.socket,disable-ticketing=on
)
[[ "${QEMU_EXTRA:-""}" != "" ]] && args=("${args[@]}" "${QEMU_EXTRA[@]}" )
[[ "${QEMU_UEFI:-""}" != "" ]] && args=("${args[@]}" -bios "${OVMF}")

sudo qemu-system-x86_64 \
  -nodefaults \
  -machine 'pc,accel=kvm' \
  -cpu 'host' \
  -smp '4,cores=2' \
  -nic 'user,model=virtio-net-pci' \
  -enable-kvm \
  -monitor "unix:/tmp/qemu-monitor-socket-${1},server,nowait" \
  -device intel-hda -device hda-duplex \
  -device virtio-serial \
  # -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=3 \
  "${args[@]}" &
set -x
pid=$!
sleep 1
sudo chown cole:cole /tmp/qemu.socket
trap 'sudo kill $pid' EXIT
remote-viewer spice+unix:///tmp/qemu.socket &
wait $pid
  # -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  # -chardev spicevmc,id=spicechannel0,name=vdagent \
  # -device virtserialport,chardev=charchannel1,id=channel1,name=org.spice-space.stream.0 \
  # -chardev spiceport,name=org.spice-space.stream.0,id=charchannel1 \
