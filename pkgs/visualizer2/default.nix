{ stdenv, lib, rustPlatform, fetchFromGitHub
}:

let
  metadata = import ./metadata.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "visualizer2";
  version = metadata.rev;

  src = fetchFromGitHub {
    inherit (metadata.github) owner repo;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with lib; {
    verinfo = metadata;
    description = " OpenGL Audio Visualizers in Rust";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
