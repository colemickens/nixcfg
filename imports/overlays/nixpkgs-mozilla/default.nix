let
  metadata = import ./metadata.nix;
in
{
  version = metadata.rev;
  name = "nixpkgs-mozilla-${metadata.rev}";

  src = builtins.fetchTarball {
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${metadata.rev}.tar.gz";
    sha256 = metadata.sha256;
  };
}
