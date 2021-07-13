{ pkgs, config, ... }:

{
  config = {
    programs.adb.enable = true;
    users.users."cole".extraGroups = [ "adbusers" ];
  };
}
