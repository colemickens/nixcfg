{ pkgs, lib, inputs, ... }:

let
in
{
  config = {
    security.pam = {
      u2f = {
        enable = true;
      };
    };
  };
}
