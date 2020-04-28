let
  metadata = import ./metadata.nix;
in
builtins.fetchTarball {
  url = "https://github.com/colemickens/nixpkgs/archive/${metadata.rev}.tar.gz";
  sha256 = metadata.sha256;
}
