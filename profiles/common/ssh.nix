{ config, lib, pkgs, ... };

let
in
{
  openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
}

