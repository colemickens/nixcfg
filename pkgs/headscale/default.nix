{ stdenv, lib, buildGoModule, fetchFromGitHub
, pkg-config, makeDesktopItem
, gtk3, libhandy, gspell
, wrapGAppsHook
}:

let
  metadata = rec {
    repo_git = "https://github.com/juanfont/headscale";
    branch = "main";
    rev = "dec4ee5f73249cb71156f5442557dc7a9f9cb8f1";
    sha256 = "sha256-/TStOT5fZLP37TD2worYPFVt/+FPDhi5aJStR78OEDI=";
    vendorSha256 = "sha256-WWWRCRZ+Pi9BvsB56a1YREjJ5gzs9eyjEswRG3CNxBo=";
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
