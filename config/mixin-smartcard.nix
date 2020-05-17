{ pkgs, config, ... }:

{
  config = {
    services.pcscd.enable = true;
  };
}
