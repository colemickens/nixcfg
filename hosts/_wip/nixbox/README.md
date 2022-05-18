# nixbox_dash

Goal is to build a xbox dashboard with the open source `nxdk`
and then see it booting with `xemu` with the non-free default mcpx bios.

This is opposed to `nixbox_linux` where I want to just boot
linux on a regular `ext3` via the open source `cromwell`.





## "nixos-on-xbox"

clickbait, oh well. (really using not-os)


## todo

- create mkhdd.sh to force the hdd image with our custom vmlinuz
- port the tools that xboxhdm include
  - mkfs.fatx (xboxdumper)
  - xboxhd (hd management script)

- https://github.com/mborgerson/fatx?

## notes

from xboxhdm_1.9:

The basis tools are provided by busybox. Furthermore I included :
 mkfs.fatx (from xboxdumper), xboxhd (the hd management script),
 lynx (console-based web-browser) and the eject tool.


> Thanks to everybody I borrowed code from...
 Most init-scripts are from the xlinux distro.
 Thanks to xbox-linux for their fatx-patches.
 and their hdkey generation algorithm (SpeedBump, Franz Lehner,...)
 Thanks to all testers who helped discovering bugs.

=>> xboxhdm1.9
- looks like we:
  - boot freeboot.img
  - someone extrtacted those files to GH
  - xboxhd2 boots the image containing xboxhd
  - fatxImage is a bootable second-stage image
  - it has the good stuff (fatx enabled kernel, mkfs.fatx, and the xboxhd script that does it all)

script to start from here:
 https://github.com/mborgerson/fatx/issues/8