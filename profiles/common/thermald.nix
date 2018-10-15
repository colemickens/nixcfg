{ config, lib, pkgs, ... }:

with lib;

let
in
{
  config.services.thermald.enable = true;
}
