{
  config,
  lib,
  pkgs,
  input,
  ...
}:

{
  config = {
    services.aria2 = {
      enable = true;
      downloadDir = "/mnt/rclone/incoming/";
      rpcSecret = "thisisastupidpassword";
      openPorts = true;
    };
  };
}
