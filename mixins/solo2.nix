{ config, pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [ solo2-cli ];
  };
}
