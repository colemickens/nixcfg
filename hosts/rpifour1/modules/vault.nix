{ pkgs, config, ... }:

let
  foo = "bar";
in {
  services.vault = {
    enable = true;
  };
}
