{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
}:

let metadata = import ./metadata.nix; in
rustPlatform.buildRustPackage rec {
  pname = "bb";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "epilys";
    repo = "bb";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  cargoSha256 = metadata.cargoSha256;

  meta = with stdenv.lib; {
    description = "simple process viewer in rust";
    homepage = "https://nessuent.xyz/bb.html";
    license = licenses.gpl3;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
