{ ... }:

{
  config = {
    environment.pathsToLink = [ "/share/bash" ]; # TODO: validate if needed

    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        programs.bash = {
          enable = true;
          historyFile = "${hm.config.xdg.dataHome}/bash/bash_history";
        };
      };
  };
}
