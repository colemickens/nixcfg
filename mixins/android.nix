{ pkgs, ... }:

{
  config = {
    programs.adb.enable = true;
    users.users."cole".extraGroups = [ "adbusers" ];

    environment.systemPackages = with pkgs; [
      rkdeveloptool
      rkflashtool
      scrcpy
    ];
  };
}
