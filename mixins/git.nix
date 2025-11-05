{ config, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.git = {
          enable = true;
          signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK7kPNqHXubFXq4k+15xz9ICn7IBd3Qfz7cawBsRzEO colemickens-sshkey";
          signing.format = "ssh";
          signing.signByDefault = false;
          signing.signer = (pkgs.writeShellScript "sign-colemickens_gmail" ''
            #!/usr/bin/env sh
            export SSH_AUTH_SOCK=/Users/cole/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
            exec ${pkgs.openssh}/bin/ssh-keygen "''${@}"
          '').outPath;
          settings = {
            user.email = "cole.mickens@gmail.com";
            user.name = "Cole Mickens";
          };

          extraConfig = {
            init = {
              defaultBranch = "main";
            };
            core = {
              untrackedCache = true;
            };
          };

          ignores = [
            ".direnv"
            ".vscode"
            ".DS_Store"
          ];

          includes = [
            {
              condition = "gitdir:~/work/";
              contents = {
                user = {
                  name = "Cole Mickens";
                  email = "cole.mickens@determinate.systems";
                  signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgyMox3ncUMQo9zNCpnh1lWuTJNLuEPWrRHmzAUZl9G  colemickens-detsys-ssh";
                  signer = (pkgs.writeShellScript "sign-colemickens_determinate_systems" ''
                    #!/usr/bin/env sh
                    export SSH_AUTH_SOCK=/Users/cole/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
                    exec ${pkgs.openssh}/bin/ssh-keygen "''${@}"
                  '').outPath;
                };
                gpg.format = "ssh";
              };
            }
          ];
        };
      };
  };
}
