{ stdenv, buildGoModule
#, fetchgit
, fetchFromGitHub
}:

let metadata = import ./metadata.nix; in
buildGoModule rec {
  pname = "niche";
  version = metadata.rev;

  # src = fetchgit {
  #   url = "https://github.com/colemickens/niche";
  #   rev = metadata.rev;
  #   sha256 = metadata.sha256;
  # };

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "niche";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://github.com/colemickens/niche";
    description = "self service Nix binary cache tool";
    license = licenses.mit;
    maintainers = with maintainers; [ colemickens ];
    platforms = platforms.unix;
  };
}
