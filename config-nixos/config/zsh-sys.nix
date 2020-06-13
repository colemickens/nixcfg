{ pkgs, ... }:

{
  config = {
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
