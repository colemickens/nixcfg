{ pkgs, lib, inputs, modulesPath, ... }:

{
  imports = [
    #../../mixins/common.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  config = {
    # TODO move to devenv
    system.stateVersion = "20.03"; # Did you read the comment?

    nix = {
      package = pkgs.nix.overrideAttrs(old: {
        src = pkgs.fetchFromGitHub {
          owner = "obsidiansystems";
          repo = "nix";
          rev = "ipfs-develop";
          sha256 = "sha256-6jLx7Vtg3FujU3mR55B97X5GM90KZUtPVb2ggIKmEjg=";
        };
      });
    };

    networking.hostName = "testipfsvm";
  };
}
