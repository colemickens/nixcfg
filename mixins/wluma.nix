{ config, pkgs, lib, ... }:

{
  config = {
    # home...
    environment.systemPackages = with pkgs; [
      wluma
    ];
  };
}
