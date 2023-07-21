{ pkgs, lib, config, inputs, ... }:

{
  config = {
    services = {
      # LOL doesn't seem to get it right at all:
      # automatic-timezoned.enable = true;
    };
  };
}
