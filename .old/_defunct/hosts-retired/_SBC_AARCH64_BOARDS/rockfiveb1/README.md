with updated u-boot + kernel:

```
Welcome to NixOS 22.11 (Raccoon)!

[   11.977011] systemd[1]: bpf-lsm: Failed to load BPF object: No such process
[  OK  ] Stopped initrd-switch-root.service.
[  OK  ] Created slice Slice /system/getty.
[  OK  ] Created slice Slice /system/modprobe.
[  OK  ] Created slice Slice /system/serial-getty.
[  OK  ] Created slice Slice /system/systemd-fsck.
[  OK  ] Created slice User and Session Slice.
[  OK  ] Started Dispatch Password …ts to Console Directory Watch.
[  OK  ] Started Forward Password R…uests to Wall Directory Watch.
[  OK  ] Reached target Local Encrypted Volumes.
[  OK  ] Stopped target initrd-fs.target.
[  OK  ] Stopped target initrd-root-fs.target.
[  OK  ] Stopped target initrd-switch-root.target.
[  OK  ] Reached target Containers.
[  OK  ] Reached target Path Units.
[  OK  ] Reached target Remote File Systems.
[  OK  ] Reached target Slice Units.
[  OK  ] Reached target Swaps.
[  OK  ] Listening on Process Core Dump Socket.
[  OK  ] Listening on Network Service Netlink Socket.
[  OK  ] Listening on Userspace Out-Of-Memory (OOM) Killer Socket.
[  OK  ] Listening on udev Control Socket.
[  OK  ] Listening on udev Kernel Socket.
         Mounting POSIX Message Queue File System...
         Mounting Kernel Debug File System...
         Starting Create List of Static Device Nodes...
         Starting Load Kernel Module configfs...
         Starting Load Kernel Module drm...
         Starting Load Kernel Module fuse...
         Starting mount-pstore.service...
[  OK  ] Stopped Journal Service.
         Starting Journal Service...
         Starting Load Kernel Modules...
         Starting Remount Root and Kernel File Systems...
         Starting Coldplug All udev Devices...
[  OK  ] Mounted POSIX Message Queue File System.
[  OK  ] Mounted Kernel Debug File System.
[  OK  ] Finished Create List of Static Device Nodes.
[  OK  ] Finished Load Kernel Module configfs.
[  OK  ] Finished Load Kernel Module drm.
         Mounting Kernel Configuration File System...
         Starting Create Static Device Nodes in /dev...
[  OK  ] Finished Load Kernel Module fuse.
         Mounting FUSE Control File System...
[  OK  ] Mounted Kernel Configuration File System.
[  OK  ] Finished mount-pstore.service.
[  OK  ] Finished Remount Root and Kernel File Systems.
[  OK  ] Finished Create Static Device Nodes in /dev.
[  OK  ] Mounted FUSE Control File System.
[  OK  ] Reached target Preparation for Local File Systems.
         Starting Load/Save Random Seed...
         Starting Rule-based Manage…for Device Events and Files...
[  OK  ] Finished Load Kernel Modules.
[  OK  ] Started Journal Service.
         Starting Firewall...
         Starting Flush Journal to Persistent Storage...
         Starting Apply Kernel Variables...
[  OK  ] Finished Apply Kernel Variables.
[  OK  ] Finished Load/Save Random Seed.
[  OK  ] Started Rule-based Manager for Device Events and Files.
[  OK  ] Finished Flush Journal to Persistent Storage.
[  OK  ] Finished Coldplug All udev Devices.
DDR Version V1.08 20220617
LPDDR4X, 2112MHz
channel[0] BW=16 Col=10 Bk=8 CS0 Row=17 CS1 Row=17 CS=2 Die BW=8 Size=4096MB
channel[1] BW=16 Col=10 Bk=8 CS0 Row=17 CS1 Row=17 CS=2 Die BW=8 Size=4096MB
channel[2] BW=16 Col=10 Bk=8 CS0 Row=17 CS1 Row=17 CS=2 Die BW=8 Size=4096MB
channel[3] BW=16 Col=10 Bk=8 CS0 Row=17 CS1 Row=17 CS=2 Die BW=8 Size=4096MB
Manufacturer ID:0x6
CH0 RX Vref:29.7%, TX Vref:23.8%,24.8%
CH1 RX Vref:26.7%, TX Vref:24.8%,24.8%
CH2 RX Vref:27.7%, TX Vref:23.8%,22.8%
CH3 RX Vref:27.7%, TX Vref:24.8%,24.8%
change to F1: 528MHz
change to F2: 1068MHz
change to F3: 1560MHz
change to F0: 2112MHz
```
