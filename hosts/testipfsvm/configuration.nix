{ pkgs, lib, inputs, modulesPath, ... }:

{
  imports = [
    ../../mixins/common.nix
    ../../mixins/ipfs.nix
    ../../profiles/user.nix
    #"${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  config = {
    # TODO move to devenv
    system.stateVersion = "21.03"; # Did you read the comment?

    nix = {
      package = lib.mkForce inputs.nix-ipfs.packages.${pkgs.system}.nix;
    };

    networking.hostName = "testipfsvm";

    services.openssh.enable = true;
  };
}
