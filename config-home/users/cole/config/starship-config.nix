{ ... }:

{
  enable = true;
  enableBashIntegration = false;
  enableFishIntegration = false;
  enableZshIntegration = false;
  settings = {
    # add_newline = false;
    prompt_order = [
      "username"
      "hostname"
      "kubernetes"
      "directory"
      "git_branch"
      "git_commit"
      "git_state"
      "git_status"
      "hg_branch"
      "docker_context"
      "package"
      "dotnet"
      "elixir"
      "elm"
      "erlang"
      "golang"
      "haskell"
      "java"
      "julia"
      "nodejs"
      "ocaml"
      "php"
      "purescript"
      "python"
      "ruby"
      "rust"
      "terraform"
      "zig"
      "nix_shell"
      "conda"
      "memory_usage"
      "aws"
      "env_var"
      "crystal"
      "cmd_duration"
      "custom"
      "line_break"
      "jobs"
      "battery"
      "time"
      "character"
    ];

    hostname.ssh_only = false;
    nix-shell.use_name = true;
    username.show_always = true;
  };
}
