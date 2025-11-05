{ config, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          jjui
        ];
        programs.jujutsu = {
          enable = true;
          settings = {
            user = {
              name = "Cole Mickens";
              email = "cole.mickens@gmail.com";
            };
            core = {
              # fsmonitor = "watchman"; NOOOOO caused serious confusing issues
            };
            signing = {
              behavior = "drop";
              backend = "ssh";
              key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK7kPNqHXubFXq4k+15xz9ICn7IBd3Qfz7cawBsRzEO colemickens-sshkey";
              backends.ssh.program = (pkgs.writeShellScript "sign-colemickens_gmail" ''
                #!/usr/bin/env sh
                export SSH_AUTH_SOCK=/Users/cole/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
                exec ${pkgs.openssh}/bin/ssh-keygen "''${@}"
              '');
            };
            git = {
              sign-on-push = true;
              # abandon-unreachable-commits = true; # ? TODO: not sure if better to do manually
            };
            ui = {
              log-synthetic-elided-nodes = true;
              # pager = ":builtin";
            };
            template-aliases = {
            };
            templates = {
              # yoink: https://github.com/cole-h/nixos-config/blob/71f2eb15b91cb7d9e8de2fa403c5842a5b8761d5/users/_common/vin/modules/jj/conf.d/templates.toml
              draft_commit_description = ''
                concat(
                  description,
                  surround(
                    "\nJJ: This commit contains the following changes:\n", "",
                    indent("JJ:     ", diff.stat(72)),
                  ),
                  "\n",
                  "JJ: ignore-rest\n",
                  diff.git(),
                )
              '';
              log_node = ''
                coalesce(
                  if(!self, label("elided", "~")),
                  label(
                    separate(" ",
                      if(current_working_copy, "working_copy"),
                      if(immutable, "immutable"),
                      if(conflict, "conflict"),
                    ),
                    coalesce(
                      if(current_working_copy, "@"),
                      if(immutable, "◆"),
                      if(conflict, "×"),
                      if(empty, "◌"),
                      "○",
                    )
                  )
                )
              '';
            };
            "--scope" = [
              {
                "--when"."repositories" = [ "~/work/" ];
                user.email = "cole.mickens@determinate.systems";
                signing.backend = "ssh";
                signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgyMox3ncUMQo9zNCpnh1lWuTJNLuEPWrRHmzAUZl9G  colemickens-detsys-ssh";
                signing.backends.ssh.program = (pkgs.writeShellScript "sign-colemickens_determinate_systems" ''
                  #!/usr/bin/env sh
                  export SSH_AUTH_SOCK=/Users/cole/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
                  exec ${pkgs.openssh}/bin/ssh-keygen "''${@}"
                '').outPath;
              }
            ];

            fix.tools.nix-fmt = {
              command = [
                "nix"
                "fmt"
              ];
              patterns = [ "glob:'**/*.nix'" ];
            };
          };
        };
      };
  };
}
