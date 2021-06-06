args_@{ lib, fetchFromGitLab, neochat
, qqc2-desktop-style, ... }:

let
  metadata = import ./metadata.nix;
  ignore = [ "neochat" "qqc2-desktop-style" ];
  args = lib.filterAttrs (n: v: (!builtins.elem n ignore)) args_;
in
(neochat.override args).overrideAttrs(old: {
  pname = "neochat";
  version = "${metadata.rev}";
  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "network";
    repo = "neochat";
    inherit (metadata) rev sha256;
  };

  buildInputs = old.buildInputs ++ [ qqc2-desktop-style ];
})
