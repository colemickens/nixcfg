{ config, pkgs, modulesPath, inputs, ... }: 

{
  imports = [
    "${modulesPath}/installer/netboot/netboot.nix"
    ../../profiles/user-cole.nix

    ../../mixins/sshd.nix

    ./oci.nix # TODO: make this a function that takes extra modules or something

    # TODO: should this entire thing be a "profile" and these other things like "cloud-mixins" ?
  ];
  config = {
    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    system.build.netbootEnv =
      let
        netboot_kernel = config.system.build.kernel;
        netboot_initrd = config.system.build.netbootRamdisk;
        netboot_ipxe = pkgs.writeText "netboot.ipxe" ''
          #!ipxe
          kernel kernel init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init initrd=initrd ${toString config.boot.kernelParams}
          initrd initrd
          boot
        '';
      in pkgs.runCommand "build-netbootEnv" { buildInputs = [ pkgs.nukeReferences ]; } ''
        mkdir $out
        ln -s "${netboot_kernel}/Image"       "$out/kernel"
        ln -s "${netboot_initrd}/initrd.zst"  "$out/initrd"
        ln -s "${netboot_ipxe}"               "$out/netboot.ipxe"
        nuke-refs $out/kernel
      '';
  };
}
