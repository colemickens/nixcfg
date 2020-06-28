{ neovim-unwrapped, fetchFromGitHub }:

let
  _rev = "721f69c4af8bc81ba04088e7b56f8cdba653b418";
  _sha256 = "1zcbv0x48yvr7llfyvb5qdpgf3rb6ccnxakah5bkz8nz42sikwlk";
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
