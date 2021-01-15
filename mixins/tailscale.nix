{ pkgs, config, ... }:

{
  config = {
    services.tailscale.enable = true;
  };
}
