{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
}:

let
  metadata = rec {
    repo_git = "https://github.com/ClementTsang/bottom";
    branch = "master";
    rev = "9ef7f5d4b787b97a35c39407ce9748e11c0e2fcd";
    sha256 = "sha256-HitiraFBN65StlgQt14AxERxazHkTg2wWV1sBXMahYE=";
    cargoSha256 = "sha256-AJTNyi/jcnHXHhjytiIrEqLpGGN+HQ8bCIgSwGZ1pZw=";
    version = rev;
  };
in rustPlatform.buildRustPackage rec {
  pname = "bottom";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "ClementTsang";
    repo = "bottom";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with lib; {
    verinfo = metadata;
    description = "Yet another cross-platform graphical process/system monitor";
    homepage = "https://github.com/ClementTsang/bottom";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
