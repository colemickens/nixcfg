let
  system = builtins.currentSystem;
  #nixpkgs = import ../imports/nixpkgs/nixos-unstable;
  nixpkgs = import ../imports/nixpkgs/local;
  pkgs = import nixpkgs.pkgs {};

  nixos = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit system;
    modules = [ ../machines/vera.nix ];
  };
in
  {
    system = nixos.config.system.build.toplevel;

    vm = import (pkgs.path + "/nixos/lib/make-disk-image.nix") rec {
      inherit pkgs;
      inherit (pkgs) lib;
      config = nixos.config;
      
      postVM = ''
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $diskImage $out/disk.vhd
        rm $diskImage
      '';
      
      name = "vera-vm";
      diskSize = 2000;
      partitionTableType = "efi";
      fsType = "ext4";
    };
  }
