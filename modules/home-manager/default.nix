{ pkgs, ... }:

{
  imports = [ (import "../pkgs/home-manager") ];
  config = {
    home-manager.users.cole = {
      package = pkgs.gitAndTools.gitFull;
      programs.git = {
        enable = true;
        userName  = "Cole Mickens";
        userEmail = "cole.mickens@gmail.com";
      };
      extraConfig = {
        core.editor = "nvim";
      };
    };
  };
}