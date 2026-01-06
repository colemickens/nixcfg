{ pkgs, ... }:

{
  config = {
    users.users."cole".extraGroups = [ "adbusers" ];

    environment.systemPackages = with pkgs; [
      android-tools
      rkdeveloptool
      rkflashtool
      scrcpy
    ];
  };
}
