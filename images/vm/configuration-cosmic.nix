{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  hn = "vm-cosmic";
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
    ../installer/configuration-base.nix

    ../../profiles/gui-cosmic.nix
  ];

  config = {
    networking.hostName = hn;
    system.nixos.tags = [ "cosmic" ];

    virtualisation = {
      # enable = true;
      diskImage = "/tmp/${config.system.name}.qcow2";
      memorySize = 4096;
      cores = 4;
      # opengl = true;
    };

    services.timesyncd.enable = lib.mkForce false;

    # environment.variables = {
    #   "WLR_NO_HARDWARE_CURSORS" = "1";
    # };

    # probably only works with mesa-y platforms (so, no nvidia)
    hardware.opengl.enable = true;

    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        ### misc
        "google-chrome"
        "google-chrome-dev"
      ];
  };
}
