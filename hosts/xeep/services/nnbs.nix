{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  netbootServer = "192.168.1.10"; # TODO: de-dupe across netboot-client.nix?
in
{ }
