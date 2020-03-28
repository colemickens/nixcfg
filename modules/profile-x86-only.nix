{ pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      esphome
    ];
  };
}
