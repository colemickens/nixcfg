{ pkgs, ... }:

{
  config = {
    # symlink root's ssh config to ours
    # to fix nix-daemon's ability to remote build

    # though maybe not
    home-manager.users.cole = { pkgs, ... }: {
      programs.ssh = {
        enable = true;
        controlMaster = "auto";
        controlPersist = "10m";
        matchBlocks = {
          "*" = {
            identityFile = "/home/cole/.ssh/id_ed25519";
          };
          "aarch64.nixos.community" = {
            hostname = "aarch64.nixos.community";
            user = "colemickens";
            port = 22;
          };
        };
      };
    };
  };
}