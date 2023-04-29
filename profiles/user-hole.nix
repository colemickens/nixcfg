let
  user = "hole";
  idno = 1001;
in
{
  config = {
    users.extraGroups."${user}".gid = idno;
    users.extraUsers."${user}" = {
      isNormalUser = true;
      home = "/tmp/home-${user}";
      description = "vpn account";
      extraGroups = [
        "audio"
        "video"
        "sound"
        "pulse"
        "input"
        "render"
        "dialout"
        "keys"
        "users"
      ];
      uid = idno;
      group = user;
    };
  };
}
