{ config, pkgs, lib, ... }:

let
  nmModule = "";
in
{
  config = {
    networking.networkmanager.useMinimalBasePackages = true;
  };
}

