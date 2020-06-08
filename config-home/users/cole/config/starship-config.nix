{ ... }:

{
  enable = true;
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

    # aws = {
    #   symbol = " ";
    # };

    # battery = {
    #   full_symbol = "";
    #   charging_symbol = "";
    #   discharging_symbol = "";
    # };

    # conda = {
    #   symbol = " ";
    # };

    # docker = {
    #   symbol = " ";
    # };

    # elixir = {
    #   symbol = " ";
    # };

    # elm = {
    #   symbol = " ";
    # };

    # git_branch = {
    #   symbol = " ";
    # };

    # golang = {
    #   symbol = " ";
    # };

    # haskell = {
    #   symbol = " ";
    # };

    # hg_branch = {
    #   symbol = " ";
    # };

    # java = {
    #   symbol = " ";
    # };

    # julia = {
    #   symbol = " ";
    # };

    # memory_usage = {
    #   symbol = " ";
    # };

    # nix_shell = {
    #   symbol = " ";
    # };

    # nodejs = {
    #   symbol = " ";
    # };

    # package = {
    #   symbol = " ";
    # };

    # php = {
    #   symbol = " ";
    # };

    # python = {
    #   symbol = " ";
    # };

    # ruby = {
    #   symbol = " ";
    # };

    # rust = {
    #   symbol = " "
    # };
  };
}
