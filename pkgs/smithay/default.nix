{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
}:

let
  metadata = rec {
    repo_git = "https://github.com/Smithay/smithay";
    branch = "master";
    rev = "242272a1d95a05c9ff62f1adf102bb807661cc45";
    sha256 = "sha256-xK6kP9B69BH29o12pu5CRr1YrnyOdWqKAQN14nqvwzo=";
    cargoSha256 = "0000000000000000000000000000000000000000000000000000";
    version = rev;
  };
in rustPlatform.buildRustPackage rec {
  pname = "smithay";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "Smithay";
    repo = "smithay";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with lib; {
    verinfo = metadata;
    description = "A smithy for rusty wayland compositors";
    homepage = "https://github.com/Smithay/smithay";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
