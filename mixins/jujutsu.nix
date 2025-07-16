{ config, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          lazyjj
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
              backend = "gpg";
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
                signing.key = config.sops.secrets."github-signingkey-detsys".path;
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
