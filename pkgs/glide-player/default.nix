args_@{ lib
, fetchFromGitHub
# , qqc2-desktop-style, sonnet, kio
# , extra-cmake-modules
, rustPlatform
, pkg-config
, gtk3
, ... }:

let
  metadata = rec {
    repo_git = "https://github.com/philn/glide";
    branch = "master";
    rev = "176bee9b2aa25e99a7057c7cbf2bc09eb1f36466";
    sha256 = "sha256-hgjJ/HcdFFUQx+Sp/ERIbU4+AyDF4TA4J/tm6PwBG+A=";
    cargoSha256 = "sha256-DeesVLYMo7vtR6nRUpFSkkFM3g/8+JH0+atMUw2pVbI=";
  };
in 
rustPlatform.buildRustPackage rec {
  pname = "glide-player";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "philn";
    repo = "glide";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk3 ];

  cargoSha256 = metadata.cargoSha256;

  meta = with lib; {
    verinfo = metadata;
    description = "Linux/macOS media player based on GStreamer and GTK";
    homepage = "https://github.com/philn/glide";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
