{ pkgs, ... }:

{
  config = {
    # see profiles/desktop-<foo>.nix for xdg-portal stuff
    
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        xdg_utils
      ];
      xdg.userDirs = {
        enable = true;
        desktop = "\$HOME/desktop";
        documents = "\$HOME/documents";
        download = "\$HOME/downloads";
        music = "\$HOME/documents/music";
        pictures = "\$HOME/documents/pictures";
        publicShare = "\$HOME/documents/public";
        templates = "\$HOME/documents/templates";
        videos = "\$HOME/documents/videos";
      };
    };
  };
}
