let
  metadata = import ./metadata.nix;
in
{
  version = metadata.rev;
  name = "nixos-hardware-${metadata.rev}";

  src = builtins.fetchTarball {
    url = "https://github.com/nixos/nixos-hardware/archive/${metadata.rev}.tar.gz";
    sha256 = metadata.sha256;
  };
}
