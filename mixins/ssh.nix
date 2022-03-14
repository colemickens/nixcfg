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
        ln -sf /home/cole/.ssh/known_hosts /root/.ssh/known_hosts
      '';
      deps = [];
    };

    # though maybe not
    home-manager.users.cole = { pkgs, lib, ... }: {
      programs.ssh = {
        enable = true;
        controlMaster = "auto";
        controlPath = "/home/cole/.ssh/%C"; # TODO: lolwut
        controlPersist = "1m";
        serverAliveInterval = 5;
        serverAliveCountMax = 2;
        matchBlocks = {
          "*" = {
            # look, idk, I think doing this myself by hand will be best:
            #  if /run/user/1000/sshagent is missing, or a bad path,
            #    then try to set it to S.gpg-agent.ssh
            #    or SSH_AUTH_SOCK if it's something provided via ssh-login
            #  -- that way, we control the sshagent path at all times
            #    and just like we can forward or gpg-fix to get our gpg sock,
            #    now we will control our own ssh sock too (makes tmux easier too)
            identityAgent = "/run/user/1000/sshagent";
            serverAliveInterval = 11;
          };
        };
      };
    };
  };
}
