let
  meta = import ./metadata.nix;
in
{
  inherit meta;
  pkgs = /home/cole/code/nixpkgs;
}
