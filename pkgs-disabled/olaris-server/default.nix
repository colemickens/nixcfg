{ stdenv, lib, buildGoModule, fetchFromGitlab, olaris-react
, pkg-config, makeDesktopItem
, gtk3, libhandy, gspell
, wrapGAppsHook
}:

let metadata = import ./metadata.nix; in
buildGoModule rec {
  pname = "olaris-server";
  version = metadata.rev;

  src = fetchFromGitlab {
    owner = "olaris";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  # nativeBuildInputs = [
  #   pkg-config
  # ];
  # buildInputs = [
  #   gtk3 libhandy libhandy gspell
  #   wrapGAppsHook
  # ];

  subPackages = [ "." ];

  meta = with lib; {
    homepage = "https://gitlab.com/olaris/olaris-server";
    description = "Olaris is an open-source, community driven, media manager and transcoding server.";
    license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
    platforms = platforms.linux;
  };
}
