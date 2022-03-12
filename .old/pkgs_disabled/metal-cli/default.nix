args_@{ lib
, buildGoModule
, fetchFromGitHub
, packet-cli
, ... }:

let
  metadata = import ./metadata.nix;
  extraNativeBuildInputs = [
    
  ];
  extraBuildInputs = [
    
  ];
  ignore = [ "lib" "packet-cli" "buildGoModule" "fetchFromGithub" ] ++ extraBuildInputs;
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_ // {
    buildGoModule = args: buildGoModule (args // {
      vendorSha256 = metadata.vendorSha256;
      src = newsrc;
      version = metadata.rev;
    });
  };
  newsrc = fetchFromGitHub {
    owner = "equinix";
    repo = "metal-cli";
    inherit (metadata) rev sha256;
  };
in
(packet-cli.override args).overrideAttrs(old: {
  pname = "metal-cli";
  version = "${metadata.rev}";
  src = newsrc;

  buildInputs = (old.buildInputs or []) ++ (map (n: args_.${n}) extraBuildInputs);
  nativeBuildInputs = (old.nativeBuildInputs or []) ++ (map (n: args_.${n}) extraNativeBuildInputs);
})
