let
  metadata = import ./metadata.nix;
in
{
  version = metadata.rev;
  name = "nixpkgs-colemickens-${metadata.rev}";

  src = builtins.fetchTarball {
    url = "https://github.com/colemickens/nixpkgs-wayland/archive/${metadata.rev}.tar.gz";
    sha256 = metadata.sha256;
  };
}
