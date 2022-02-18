{ stdenv, lib, buildGoModule, fetchFromGitHub
, pkg-config, makeDesktopItem
, gtk3, libhandy, gspell
, wrapGAppsHook
}:

let
  metadata = rec {
    repo_git = "https://github.com/juanfont/headscale";
    branch = "main";
    rev = "7d5e6d3f0ffcae5dc9b1f47964f34b5b3b663873";
    sha256 = "sha256-vpYxU4CDKnBlYkCaIk9v2CGQD2BlKc3LE33SMoebFd0=";
    vendorSha256 = "sha256-v76UWaF6kdmuvABg6sDMmDpJ4HWvgliyEWAbAebK3wM=";
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
