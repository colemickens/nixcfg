{ pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [ cachix ];
  };
}
