{ inputs }:

let
  pkgs = import inputs.nixpkgs {
    system = "i686-linux";
  };
  img = "bzImage";

  ## FAT-X KERNEL
  xboxhdm19src = builtins.fetchTarball {
    url = "https://archive.org/download/xboxhdm_v1.9/xboxhdm_1.9.tar.zst";
    sha256 = "1yl6k3r4xflg5swsh85385n2kaw2q1giahliha1nwjykhh23c339";
  };
  fatxKernel = pkgs.runCommand "fatxKernel" {} ''
    mkdir $out
    cp ${xboxhdm19src}/xboxhdm/linux/isolinux/fatxImage $out/${img}
  '';
  # TODO: build the fatx-enabled 2.6 kernel from scratch

  ## FAT-X KERNEL
  xboxLinux26  = { fetchFromGitHub, fetchurl, fetchpatch, buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "2.6.22";
      modDirVersion = version;

      src = fetchurl {
        url = "mirror://kernel/linux/kernel/v2.6/linux-${version}.tar.xz";
        sha256 = "sha256-F4kGyVW9R99hs11sIDYWMBR3lPG98Z0Wcvep6wnGUqU=";
      };

      kernelPatches = [
        {
          name = "linux-2.6-xbox";
          patch = ./linux-2.6.22.7-xbox.patch;
        }
      ];

      defconfig = "xbox_defconfig";

      extraMeta.branch = "2.6";
    } // (args.argsOverride or {}));
  linux_fatx = pkgs.callPackage xboxLinux26 {};
  kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux_fatx);

  ## XBOXDUMPER (MKFS.FATX)
  xboxdumper = pkgs.stdenv.mkDerivation {
    name = "xboxdumper";
    src = builtins.fetchTarball {
      url = "https://archive.org/download/xboxdumper.src.tar/xboxdumper.src.tar.bz2";
      sha256 = "1gklghq4038681mnjn8xjsjhjd7ixf287ayx18q1ywj7k4sgpcmv";
    };
    makeFlags = [ "DESTDIR=$(out)" ];
    postPatch = ''
      sed -i 's/-static //g' Makefile
      mkdir -p $out/sbin
    '';
    postInstall = ''
      mv $out/sbin $out/bin
    '';
  };

  ## NXDK
  nxdk = {};

  ## DASHBOARD
  nevolutionx = {};

  ## C-DRIVE
  xbox_c =  pkgs.runCommand "xbox_c_drive" {} ''
    mkdir $out
    touch $out/empty_c_drive
    #cp $nevolutionx}/bin/xboxdash.xbe $out/xboxdash.xbe
  '';

  ## E-DRIVE
  xbox_e =  pkgs.runCommand "xbox_e_drive" {} ''
    mkdir $out
    touch $out/empty_e_drive
  '';

  ## PUT IT ALL TOGETHER
  runInLinuxVM = (import "${inputs.nixpkgs}/pkgs/build-support/vm/default.nix" {
    kernel = linux_fatx;
    #kernel = fatxKernel;
    rootModules = [];
    img = img;
    inherit pkgs;
    lib = pkgs.lib;
  }).runInLinuxVM;

  image = runInLinuxVM (
    pkgs.stdenv.mkDerivation {
      name = "build-xbox-image";
      buildInputs = [ pkgs.util-linux ];
      buildCommand = ''
        set -e

        mkdir -p $out
        disk="$out/disk.raw"
        HEAD="${xboxhdm19src}/xboxhdm/linux/xbox/head.raw
        FATX="${xboxhdm19src}/xboxhdm/linux/xbox/fatx.raw

        dd if=/xboxhdm/xbox/$HEAD of=$disk               bs=512k
        dd if=/xboxhdm/xbox/$FATX of=$disk seek=1        bs=512k
        dd if=/xboxhdm/xbox/$FATX of=$disk seek=1501     bs=512k
        dd if=/xboxhdm/xbox/$FATX of=$disk seek=3001     bs=512k
        dd if=/xboxhdm/xbox/$FATX of=$disk seek=4501     bs=512k
        dd if=/xboxhdm/xbox/$FATX of=$disk seek=5501     bs=512k
        dd if=/xboxhdm/xbox/$FATX of=$disk seek=15633072 bs=512

        x_drive="$(losetup --show -f -o 524288 --sizelimit 786432000 $disk)"
        y_drive="$(losetup --show -f -o 786956288 --sizelimit 786432000 $disk)"
        z_drive="$(losetup --show -f -o 1573388288 --sizelimit 786432000 $disk)"
        c_drive="$(losetup --show -f -o 2359820288 --sizelimit 524288000 $disk)"
        e_drive="$(losetup --show -f -o 2884108288 --sizelimit 5120024576 $disk)"
        f_drive="$(losetup --show -f -o 8004132864 $disk)"

        ${xboxdumper}/bin/mkfs.fatx $c_drive
        ${xboxdumper}/bin/mkfs.fatx $e_drive
        ${xboxdumper}/bin/mkfs.fatx $f_drive
        ${xboxdumper}/bin/mkfs.fatx $x_drive
        ${xboxdumper}/bin/mkfs.fatx $y_drive
        ${xboxdumper}/bin/mkfs.fatx $z_drive

        mount $c_drive /mnt/xboxtmp
        cp -r ${xbox_c}/* /mnt/xboxtmp/
        umount /mnt/xboxtmp

        mount $e_drive /mnt/xboxtmp
        cp -r ${xbox_e}/* /mnt/xboxtmp/
        umount /mnt/xboxtmp

        losetup -d $x_drive
        losetup -d $y_drive
        losetup -d $z_drive
        losetup -d $c_drive
        losetup -d $e_drive
        losetup -d $f_drive
      '';
    });
in
  image
