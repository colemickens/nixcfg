{ stdenv, lib, buildGoModule, fetchFromGitHub
, pkg-config, makeDesktopItem
, gtk3, libhandy, gspell
, wrapGAppsHook
}:

let metadata = import ./metadata.nix; in
buildGoModule rec {
  pname = "cchat-gtk";
  version = metadata.rev;

  src = fetchFromGitHub {
    owner = "diamondburned";
    repo = pname;
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  vendorSha256 = metadata.vendorSha256;

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    gtk3 libhandy libhandy gspell
    wrapGAppsHook
  ];

  subPackages = [ "." ];

  postInstall = ''
    cp -r ${
      makeDesktopItem {
        name = "cchat-gtk";
        exec = "@out@/bin/cchat-gtk";
        #terminal = "true";
        desktopName = "cchat-gtk";
        genericName = "cchat client";
        categories = "Network;Chat";
        comment = meta.description;
      }
    }/* $out/
    substituteAllInPlace $out/share/applications/*
  '';

  meta = with lib; {
    homepage = "https://github.com/diamondburned/cchat-gtk";
    description = "Gtk frontend for cchat";
    license = licenses.gpl3;
    maintainers = with maintainers; [ colemickens ];
    platforms = platforms.linux;
  };
}
