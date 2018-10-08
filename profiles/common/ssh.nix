{ config, lib, pkgs, ... }:

let
in
{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
}

