#!/usr/bin/env nu

let script = $"
dhcp

setenv bootargs 'console=tty1 console=ttyS0,115200 debug earlycon=sbi'
setenv serverip 192.168.1.99
tftpboot ${kernel_addr_r} kernel
tftpboot ${ramdisk_addr_r} initrd
setenv ramdisk_filesize ${filesize}
tftpboot ${fdt_addr_r} dtb
echo ${bootargs}
booti ${kernel_addr_r} ${ramdisk_addr_r}:${ramdisk_filesize} ${fdt_addr_r}"

let script = ($script | str trim | str replace --all "\n" '; ')

print -e $script

print -e "go go go!"
sleep 3sec
wtype $script
