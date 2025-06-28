{ config, ... }:

{
  config = {
    sops.secrets = {
      "github-signingkey-detsys" = {
        format = "binary";
        sopsFile = ../secrets/encrypted/github-signingkey-detsys;
        owner = "cole";
        group = "cole";
        mode = "0600";
      };
      "github-colebot-sshkey" = {
        mode = "0600";
        sopsFile = ../secrets/encrypted/github-colebot-sshkey;
        format = "binary";
      };
    };

    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.git = {
          enable = true;
          signing.key = "8329C1934DA5D818AE35F174B475C2955744A019";
          # signing.signByDefault = true;
          signing.signByDefault = false;
          userEmail = "cole.mickens@gmail.com";
          userName = "Cole Mickens";

          extraConfig = {
            init = {
              defaultBranch = "main";
            };
            core = {
              untrackedCache = true;
              # fsmonitor = "${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor";
            };
            safe = {
              directory = "/home/cole/code/nixcfg";
            };
          };

          ignores = [
            ".direnv"
            ".vscode"
          ];

          includes = [
            {
              condition = "gitdir:~/work/";
              contents = {
                user = {
                  name = "Cole Mickens";
                  email = "cole.mickens@determinate.systems";
                  # signingkey = "/run/secrets/github-signingkey-detsys";
                  signingkey = config.sops.secrets."github-signingkey-detsys".path;
                };
                gpg.format = "ssh";
              };
            }
            {
              condition = "gitdir:~/work/_colebot/code/";
              contents =
                let
                  idfile = config.sops.secrets."github-colebot-sshkey".path; # TODO: this only works because its set with github-runner
                in
                {
                  core = {
                    sshCommand = "ssh -v -o IdentitiesOnly=true -i ${pkgs.lib.escapeShellArgs [ idfile ]}";
                  };
                  user = {
                    # TODO: does this erroneously misrepresent my manual actions as the bot?/
                    name = "colebot";
                    email = "colemickens+colebot@gmail.com";
                  };
                };
            }
          ];
          delta = {
            enable = true;
            options = {
              features = "decorations side-by-side navigate";
              syntax-theme = "TwoDark";
            };
          };

          # difftastic = {
          #   enable = true;
          # };
        };
      };
  };
}
