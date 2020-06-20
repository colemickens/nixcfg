{ neovim-unwrapped, fetchFromGitHub }:

let
  _rev = "5f0a1b04c1630f3b685382f881e439b7d4f2feb3";
  _sha256 = "sha256:069jgjhb7qjvdll7nqpklx3h2przvxyg2r2yx8arsh53iw3his3z";
in
  neovim-unwrapped.overrideAttrs(old: {
     version = "0.5.0-${_rev}";
     src = fetchFromGitHub {
       owner = "neovim";
       repo = "neovim";
       rev = _rev;
       sha256 = _sha256;
     };
  })
