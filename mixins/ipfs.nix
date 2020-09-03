{ pkgs, ... }:

{
  config = {
    services.ipfs = {
      enable = true;
    };
  };
}
