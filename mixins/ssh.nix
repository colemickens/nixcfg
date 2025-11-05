{ config, ... }:

let 
  cole_fngr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK7kPNqHXubFXq4k+15xz9ICn7IBd3Qfz7cawBsRzEO colemickens-sshkey";
  cole_sock = "/Users/cole/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
  work_fngr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgyMox3ncUMQo9zNCpnh1lWuTJNLuEPWrRHmzAUZl9G  colemickens-detsys-ssh";
  work_sock = "/Users/cole/Lisrary/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  config = {
    home-manager.users.cole =
      { pkgs, lib, ... }:
      {
        home.sessionVariables = {
          SSH_AUTH_SOCK = cole_sock;
        };
        home.sessionVariablesExtra = lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") ''
          export SSH_AUTH_SOCK="${cole_sock}"
        '';
        programs.ssh = {
          enable = true;
          matchBlocks = {
            "*" = {
              # everything sucks about SSH_AUTH_SOCK, so let's just control
              # it and what it points to directly
              identityAgent = cole_sock;
              serverAliveInterval = 11;
            };
          };
        };
      };
  };
}
