{ pkgs, ... }:

{
  config = {
    services.lorri.enable = true;
    environment.systemPackages = with pkgs; [ direnv lorri ];
  };
}
