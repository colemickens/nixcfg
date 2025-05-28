{
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:

# export toplevel="/nix/store/pas2djg5n06h6g7qb7dyngp0wpc1slx2-nixos-system-ds-ws-colemickens-24.11.20241109.07247a0"
# sudo nix build \
#  --option 'extra-trusted-public-keys' 'colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4=' \
#  --option 'extra-substituters' 'https://colemickens.cachix.org' \
#  --profile /nix/var/nix/profiles/system \
#  $toplevel
# sudo $toplevel/bin/switch-to-configuration switch

let
  hn = "ds-ws-colemickens";
in
{
  imports = [
    "${modulesPath}/../maintainers/scripts/ec2/amazon-image.nix"

    # TODO: evaluate if we want this, does it conflict with 'determinate'?
    # ../../mixins/common.nix
    # common includes too many assumptions (nix, efi boot, networking, etc)
    # TODO: common gets included regardless!!!! eeeek

    inputs.determinate.nixosModules.default
    ../../profiles/user-cole.nix

    ../../mixins/clamav.nix

    ../../mixins/docker.nix

    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    ../../profiles/interactive.nix
    (import ../../profiles/addon-clouddev.nix { hostname = "ds-ws-colemickens.mickens.us"; })
    ../../profiles/addon-devtools.nix
  ];

  config = {
    # TEMP DetNix hack, hopefully to be removed soon
    environment.etc."nix/nix.conf".target = "nix/nix.custom.conf";

    nixpkgs.hostPlatform.system = "x86_64-linux";
    system.stateVersion = "24.11";

    networking.hostName = hn;
    # https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/alacritty/Tango%20Adapted.yml
    # nixcfg.common.hostColor = "#00a2ff";
    nixcfg.common.hostColor = "green";

    ec2.efi = true;

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
