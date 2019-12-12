{
  nixpkgs.config.allowUnfree = true;
  services.spotifyd = {
    enable = true;
    # TODO: externalize this file and protect with git-crypt
    config = ''
      [global]
      username = cole.mickens@gmail.com
      password = OneTwoThree
      #password_cmd = gopass show -o colemickens/spotify.com
      backend = pulseaudio
      bitrate = 320
    '';
  };
}
