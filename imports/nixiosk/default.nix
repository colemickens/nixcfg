let
  metadata = import ./metadata.nix;
in
builtins.fetchTarball {
  url = "https://github.com/matthewbauer/nixiosk/archive/${metadata.rev}.tar.gz";
  sha256 = metadata.sha256;
}
