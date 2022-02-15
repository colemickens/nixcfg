{ stdenv
, lib
, fetchFromGitHub
, rustPlatform
}:

let
  metadata = {
    repo_git = "https://github.com/epilys/bb";
    branch = "master";
    rev = "c903d4c2975509299fd3d2600a0c4c2102f445d0";
    sha256 = "sha256-KOXK+1arUWtu/QU7dwXhojIM0faMtwNN3AqVbofq1lY=";
    cargoSha256 = "sha256-3UZYGKYs4o/Gp88puano5HU6PQkmQD/YYYQAq4UvEjU=";
  };
in rustPlatform.buildRustPackage rec {
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
    verinfo = metadata;
    description = "simple process viewer in rust";
    homepage = "https://nessuent.xyz/bb.html";
    license = licenses.gpl3;
    maintainers = with maintainers; [];
    platforms = platforms.linux;
  };
}
