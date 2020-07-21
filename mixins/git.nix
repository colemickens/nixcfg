{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.git = {
        enable = true;
        signing.key = "8329C1934DA5D818AE35F174B475C2955744A019";
        signing.signByDefault = true;
        userEmail = "cole.mickens@gmail.com";
        userName = "Cole Mickens";
      };
    };
  };
}