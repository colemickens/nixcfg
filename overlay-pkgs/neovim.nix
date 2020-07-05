{ neovim-unwrapped, fetchFromGitHub }:

let
  _rev = "bd5f0e9695cb21c8b97f844ce21432ee8d06b7ed";
  _sha256 = "sha256-9c8X3FRO/b0VDyC6v0ZSR1XazziuHzKtaPVRowoT1Ho=";
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
