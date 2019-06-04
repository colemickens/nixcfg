let
  mkSystem = (import ./lib.nix {}).mkSystem;
in rec {
  xeep__nixos-unstable = mkSystem rec {
    inherit (import ./imports/nixpkgs/nixos-unstable/metadata.nix) rev sha256 owner repo;
    configFile = import ./machines/xeep.nix;
    nixpkgs = builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
  };
  xeep__cmpkgs = mkSystem rec {
    inherit (import ./imports/nixpkgs/cmpkgs/metadata.nix) rev sha256 owner repo;
    configFile = import ./machines/xeep.nix;
    nixpkgs = builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      inherit sha256;
    };
  };
  xeep__local = mkSystem rec {
    configFile = ./machines/xeep.nix;
    nixpkgs = /home/cole/code/nixpkgs;
    rev = "git";
  };

  all = [
    xeep__nixos-unstable.config.system.build.toplevel
    xeep__cmpkgs.config.system.build.toplevel
    xeep__local.config.system.build.toplevel
  ];

  # vera-vm: This builds a disk image ready to go, running my services,
  # with my user account + keys added, no interactive login needed
  # TODO: make this fully true
  # azeraSys = import (pkgs.path + "/nixos/lib/eval-config.nix") {
  #   modules = [ ../machines/vera.nix ];
  # };
  # azeraDisk = {
  #   system = azeraSys.config.system.build.toplevel;

  #   vm = import (pkgs.path + "/nixos/lib/make-disk-image.nix") rec {
  #     inherit pkgs;
  #     inherit (pkgs) lib;
  #     config = output.config;
      
  #     postVM = ''
  #       ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $diskImage $out/disk.vhd
  #       rm $diskImage
  #     '';
      
  #     name = "vera-vm";
  #     diskSize = 2000;
  #     partitionTableType = "efi";
  #     fsType = "ext4";
  #   };
  # };
}