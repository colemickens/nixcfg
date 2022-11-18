{ pkgs, ... }:

let
  lib = pkgs.lib;

  tfutil = {
    userdata_str = p: "\${templatefile(\"${p.template}\", ${toVars p.uservars})}";
    userdata_b64 = p: "\${base64encode(templatefile(\"${p.template}\", ${toVars p.uservars}))}";
  };

  oracle = import ./tflib-oracle.nix {inherit pkgs tfutil;};
  equinix = import ./tflib-equinix.nix {inherit pkgs tfutil;};

  # TODO: turn this into something
  # that zips up a dir, shoves it in userdata with a script that self-extracts and runs it
      # udi = f: "\n\n##\n##\n# ${f}\n${builtins.readFile ( (process (./. + "/${f}") ) )}";

  # # TODO: TF sucks, so process function -- any ${var} that are not ${TF_} should become $${var}
  # # TODO: this doesn't work if the script has multiple bash vars per line .... fucking yuck
  # so put all TF_ type vars at top on their own line
  # TODO: is this safe to run everything through (shell embedded in nix?)
  process = input: pkgs.runCommand "processabcxyz" {nativeBuildInputs = [pkgs.coreutils];} ''
    sed '/TF_/! s/\''${\(.*\)}/$''${\1}/g' ${input} > $out
  '';

  toVars = vars: "{ " + (builtins.concatStringsSep ", " (lib.mapAttrsToList (k: v: "${k} = \"${v}\"") vars)) + " }";
in {
  util = tfutil;

  payloads = {
    nixos-generic-config = {
      template = process ./userdata/nixos-generic-config/default.nix;
      uservars = /*toVars*/ {
        TF_NIX_INSTALL_URL = "https://github.com/numtide/nix-unstable-installer/releases/download/nix-2.5pre20211026_5667822/install";
        TF_USERNAME = "cole";
        TF_NIXOS_LUSTRATE = "false";
      };
    };
    ubuntu-nixos-infect = {
      template = process ./userdata/ubuntu-nixos-infect/infect.sh;
      uservars = /*toVars*/ {};
    };
  };
  inherit oracle equinix;
}