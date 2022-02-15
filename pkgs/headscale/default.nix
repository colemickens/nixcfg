{ stdenv, lib, buildGoModule, fetchFromGitHub
, pkg-config, makeDesktopItem
, gtk3, libhandy, gspell
, wrapGAppsHook
}:

let
  metadata = rec {
    repo_git = "https://github.com/juanfont/headscale";
    branch = "main";
    rev = "73497382b7002050b85f6e919f2fc6b9616b4c80";
    sha256 = "sha256-hiUBS4DwmZUnMQfrGZWpDLU/i4ihrA/KQTNQT67xSMk=";
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
