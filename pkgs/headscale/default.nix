{ stdenv, lib, buildGoModule, fetchFromGitHub
, pkg-config, makeDesktopItem
, gtk3, libhandy, gspell
, wrapGAppsHook
}:

let
  metadata = rec {
    repo_git = "https://github.com/juanfont/headscale";
    branch = "main";
    rev = "435ee36d789995553150991404a38d3403e0c1d8";
    sha256 = "sha256-C20xJZqaRzwTnPtQUK7TIkokPTpx5tqQsfrskT43YSc=";
    vendorSha256 = "sha256-sSfDLL4lUkXTKN/XLb8W40Wvm08eUuxNO5iO0rkT9Go=";
  };
in buildGoModule rec {
  pname = "headscale";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "juanfont";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  nativeBuildInputs = [
    pkg-config
  ];
  # buildInputs = [
  #   gtk3 libhandy libhandy gspell
  #   wrapGAppsHook
  # ];

  subPackages = [ "cmd/headscale" ];

  meta = with lib; {
    verinfo = metadata;
    homepage = "https://github.com/juanfont/headscale";
    description = "An open source implementation of the Tailscale coordination server";
    license = licenses.bsd3;
    maintainers = with maintainers; [ colemickens ];
    platforms = platforms.linux;
  };
}
