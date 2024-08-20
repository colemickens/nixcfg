{
  pkgs,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          lazyjj
        ];
        programs.jj = {
          enable = true;
          package = inputs.jj.outputs.packages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
          settings = {
            user = {
              name = "Cole Mickens";
              email = "cole.mickens@gmail.com";
            };
            core = {
              fsmonitor = "watchman";
            };
            git = {
              # abandon-unreachable-commits = true; # ? TODO: not sure if better to do manually
              push-branch-prefix = "colemickens/push-";
            };
            ui = {
              log-synthetic-elided-nodes = true;
              # pager = ":builtin";
            };
            template-aliases = {
              one = ''
                if(root,
                  builtin_log_root(change_id, commit_id),
                  label(if(current_working_copy, "working_copy"),
                    concat(
                      separate(" ",
                        builtin_change_id_with_hidden_and_divergent_info,
                        if(conflict, label("conflict", "conflict")),
                        if(empty, label("empty", "(empty)")),
                        if(description, description.first_line(), description_placeholder),
                        format_short_commit_id(commit_id),
                        git_head,
                        branches,
                        tags,
                        working_copies,
                      ) ++ "\n",
                    ),
                  )
                )
              '';
            };
          };
        };
      };
  };
}
