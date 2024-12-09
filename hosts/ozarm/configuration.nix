{
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:

let
  hn = "ozarm";
in
{
  imports = [
    "${modulesPath}/../maintainers/scripts/ec2/amazon-image.nix"

    inputs.determinate.nixosModules.default
    ../../profiles/user-cole.nix

    ../../mixins/clamav.nix

    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    ../../profiles/interactive.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    system.stateVersion = "24.11";

    networking.hostName = hn;
    # https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/alacritty/Tango%20Adapted.yml
    # nixcfg.common.hostColor = "#00a2ff";
    nixcfg.common.hostColor = "green";

    services.tailscale.useRoutingFeatures = "server";
    services.udisks2.enable = lib.mkForce false;

    boot.loader.timeout = lib.mkForce 3;

    # TODO: GROSS: caused my 'ssm-user' squatting on uid=1000
    users.extraGroups."cole".gid = lib.mkForce 2000;
    users.extraUsers."cole".uid = lib.mkForce 2000;

    # TODO: GROSS: caused by mixins/common.nix being presumptive
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    boot = {
      tmp = {
        useTmpfs = false; # this seems to not give enough RAM for a kernel build
        cleanOnBoot = true;
      };
    };
  };
}
