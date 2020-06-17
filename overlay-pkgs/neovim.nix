{ neovim }:

let
  _rev = "e78658348d2b14f2366b9baf2f7ceed19184dbb6";
  _sha256 = "03p7pic7hw9yxxv7fbgls1f42apx3lik2k6mpaz1a109ngyc5kaj";
in
{
  neovim.overrideAttrs(old: {
     version = "0.5.0-${_rev}";
     src = fetchFromGitHub {
       owner = "neovim";
       repo = "neovim";
       inherit rev sha256;
       sha256 = _sha256;
     };
  });
}
