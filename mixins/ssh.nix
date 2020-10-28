{ pkgs, ... }:

{
  config = {
    # symlink root's ssh config to ours
    # to fix nix-daemon's ability to remote build since it sshs from the root account
    system.activationScripts.root_ssh_config = {
      text = ''
        mkdir -p /root/.ssh
        ln -sf /home/cole/.ssh/config /root/.ssh/config
        ln -sf /home/cole/.ssh/known_hosts /root/.ssh/known_hosts
      '';
      deps = [];
    };

    # though maybe not
    home-manager.users.cole = { pkgs, lib, ... }: {
      programs.ssh = {
        enable = true;
        controlMaster = "auto";
        controlPersist = "10m";
        matchBlocks = {
          "aarch64" = {
            hostname = "aarch64.nixos.community";
            user = "colemickens";
            port = 22;
          };
          "*" = {
            identityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh";
            forwardAgent = true;
          };
        };
      };
    };
  };
}