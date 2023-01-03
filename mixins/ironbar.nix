{ config, pkgs, lib, inputs, ... }:

{
  config = {
    programs.ironbar = {
      enable = true;
      systemd = true;
      # style = ''
      # '';
      # config = {};
    };
  };
}
