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

  postPatch = ''
    set -x
    ls ./src/main.rs
    sed -i 's/all(target_arch = "arm", target_pointer_width = "32")/any(target_arch = "arm", target_arch = "aarch64")/g' ./src/main.rs
    echo "------"
    cat ./src/main.rs
    echo "------"
    set +x
  '';

  cargoSha256 = metadata.cargoSha256;

  meta = with lib; {
    description = "simple process viewer in rust";
    homepage = "https://nessuent.xyz/bb.html";
    license = licenses.gpl3;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
