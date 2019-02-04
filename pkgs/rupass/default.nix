{ stdenv, lib, fetchFromGitHub
, rustPlatform, cmake, autoconf, pkgconfig
, ncurses, libgpgerror, gpgme
}:

with rustPlatform;

let
  metadata = import ./metadata.nix;
in buildRustPackage rec {
  name = "rupass-${version}";

  version = "git"
  src = /home/cole/code/rupass;

  #version = metadata.rev;
  #src = fetchFromGitHub {
  #  owner = "colemickens";
  #  repo = "rupass";
  #  rev = metadata.rev;
  #  sha256 = metadata.sha256;
  #};

  cargoSha256 = "0ivxn9cqzlg62jrsyd0nbalg19m5cmvqzfid8c0w1h6680w9grlr";

  nativeBuildInputs = [ cmake pkgconfig autoconf ];
  cargoBuildFlags = [ "--all" ];

  buildInputs = [
    ncurses libgpgerror gpgme
  ];

  meta = with stdenv.lib; {
    description = "rupass";
    homepage = "https://github.com/colemickens/rupass";
    maintainers = maintainers.colemickens;
    platforms = platforms.linux;
    license = with licenses; [ ]; # TODO
  };
}
