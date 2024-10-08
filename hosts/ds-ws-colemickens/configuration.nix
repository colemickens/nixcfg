{ pkgs, lib, modulesPath, inputs, ... }:

# export toplevel="$(result_from_builder)
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

    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    ../../profiles/interactive.nix
    ../../profiles/addon-clouddev.nix
    ../../profiles/addon-devtools.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    system.stateVersion = "24.05";

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
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce true;

    boot = {
      tmp = {
        useTmpfs = false; # this seems to not give enough RAM for a kernel build
        cleanOnBoot = true;
      };
    };
  };
}
