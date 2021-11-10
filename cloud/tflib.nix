{ pkgs, ... }:

let
  lib = pkgs.lib;

  oracle = import ./tflib-oracle.nix {inherit pkgs;};
  packet = import ./tflib-packet.nix {inherit pkgs;};

  udi = f: "\n\n##\n##\n# ${f}\n${builtins.readFile ( (process (./. + "/${f}") ) )}";

  # TODO: TF sucks, so process function -- any ${var} that are not ${TF_} should become $${var}
  # TODO: this doesn't work if the script has multiple bash vars per line .... fucking yuck
  process = input: pkgs.runCommandNoCC "processabcxyz" {nativeBuildInputs = [pkgs.coreutils];} ''
    sed '/TF_/! s/\''${\(.*\)}/$''${\1}/g' ${input} > $out
  '';
  ud = pkgs.writeScript "bootstrap.sh.tmpl" ''
    #!/usr/bin/env bash
    set -xeuo pipefail
    ${udi "./userdata/install-nix.sh"}
  '';
  toVars = vars: "{ " + (builtins.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = \"${v}\"") vars)) + " }";
  uv = toVars {
    TF_NIX_INSTALL_URL = "https://github.com/numtide/nix-unstable-installer/releases/download/nix-2.5pre20211026_5667822/install";
    TF_USERNAME = "cole";
    TF_NIXOS_LUSTRATE = "false";
  };
in {
  uservars = uv;
  userdata = ud;

  inherit oracle packet;
}