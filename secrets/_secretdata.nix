{ lib }:

lib.mapAttrs'
  (
    name: v:
    (lib.nameValuePair name {
      sopsFile = ./encrypted + "/${name}";
      format = "binary";
    })
  )
  (builtins.readDir ./encrypted)
