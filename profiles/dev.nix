{ config, pkgs, lib, ... }:

{
  config = {
    programs.flashrom.enable = true;
  };
}
