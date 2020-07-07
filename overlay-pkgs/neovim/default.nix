{ neovim-unwrapped, fetchFromGitHub }:

let
  metadata = import ./metadata.nix;
in
  neovim-unwrapped.overrideAttrs(old: {
     version = "0.5.0-${metadata.rev}";
     src = fetchFromGitHub {
       owner = "neovim";
       repo = "neovim";
       rev = metadata.rev;
       sha256 = metadata.sha256;
     };
  })
