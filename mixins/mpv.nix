{
  config,
  pkgs,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs.mpv = {
          enable = true;
          config = {
            # video-sync = "display-resample";
            # hwdec = "vaapi";
            # vo = "gpu";
            # hwdec-codecs = "all";
          };
        };
      };
  };
}
