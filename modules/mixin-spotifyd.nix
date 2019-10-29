{
  nixpkgs.config.allowUnfree = true;
  services.spotifyd = {
    enable = true;
    # TODO: externalize this file and protect with git-crypt
    config = ''
      [global]
      username = cole.mickens@gmail.com
      password = 52eC7pIluqv1PkJbM%osQ^D&C
      bitrate = 320
    '';
  };
}
