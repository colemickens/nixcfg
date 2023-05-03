{ pkgs, lib, config, inputs, ... }:

{
  config = {
    services = {
      automatic-timezoned.enable = true;
    };
  };
}
