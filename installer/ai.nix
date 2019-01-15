{
  hostname,
  rootDevice,
  windowsSize,
  matchMac
}:

let
  partTypeESP = "0FC63DAF-8483-4772-8E79-3D69D8477DE4";
  partTypeLUKS = "CA7D7CCB-63ED-4C53-861C-1742536059CC";
  partTypeWinRE = "DE94BBA4-06D1-4D40-A16A-BFD50179D6AC";
  partTypeWinReserved = "E3C9E316-0B5C-4DB8-817D-F92DF00215AE";
  partTypeWinBasicData = "EBD0A0A2-B9E5-4433-87C0-68B6B72699C7";
in
''
  #!${pkgs.stdenv.shell}
  set -x
  set -e

  wipefs -a ${rootDevice}

  # seems like overkill:
  #dd if=/dev/zero of=${rootDevice} bs=512 count=10000

  sfdisk ${rootDevice} <<EOF
  label: gpt
  device: ${rootDevice}
  unit: sectors
  1 : size=${toString (2048 * 512)}, type=${partTypeESP}
  2 : type=${partTypeLUKS}
  ${if windowsSize > 0 then ''
    3 : size=${toString (2048 * 512)}, type=${partTypeWinRE}
    4 : size=${toString (2048 * 128)}, type=${partTypeWinReserved}
    5 : size=${toString (2048 * windowsSize)}, type=${partTypeWinBasicData}
  ''}
  EOF

  mkdir -p /mnt

  cryptsetup luksFormat /dev/nvme0n1p2
  cryptsetup open --type luks /dev/nvme0n1p2 luksbtrfs

  mount -t btrfs /dev/mapper/luksbtrfs /mnt
  btrfs subvol create /mnt/nixos-root
  btrfs subvol create /mnt/nixos-var
  btrfs subvol create /mnt/nixos-home
  btrfs subvol create /mnt/nixos-nix
  umount /mnt

  mount -t btrfs -o subvol=/nixos-root /dev/mapper/luksbtrfs /mnt
  mount -t btrfs -o subvol=/nixos-home /dev/mapper/luksbtrfs /mnt/home
  mount -t btrfs -o subvol=/nixos-var  /dev/mapper/luksbtrfs /mnt/var
  mount -t btrfs -o subvol=/nixos-nix  /dev/mapper/luksbtrfs /mnt/nix
  mount -t vfat                        /dev/nvme0n1p1        /mnt/boot

  mkdir -p /home/nix
  mkdir -p /home/cole
  ${pkgs.git}/bin/git clone https://github.com/colemickens/nixcfg  -b master /home/nix/nixcfg
  ${pkgs.git}/bin/git clone https://github.com/colemickens/nixpkgs -b cmpkgs /home/nix/nixpkgs
  ${pkgs.git}/bin/git clone https://github.com/colemickens/dotfiles -b cmpkgs /home/cole/.dotfiles

  NIX_PATH=nixpkgs=/mnt/home/nix/nixpkgs:nixos-config=/mnt/home/nix/nixcfg/modules/config-${hostname}.nix
  nixos-install

  chown -R cole:cole /home/nix
  chown -R cole:cole /home/cole

  (cd /home/cole/.dotfiles; sudo -u cole "bash ./stow.sh")

  umount /mnt/home
  umount /mnt/nix
  umount /mnt/var
  umount /mnt/boot
  umount /mnt
''

