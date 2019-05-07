{ fetchFromGitHub }:

let
  metadata = import ./metadata.nix;
in
{
  version = metadata.rev;
  name = "nixos-hardware-${metadata.rev}";

  src = fetchFromGitHub {
    owner = "nixos";
    repo = "nixos-hardware";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };
}
