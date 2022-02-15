{ stdenv
, fetchgit
, meson, ninja, pkgconfig, scdoc
, systemd
}:

let
  metadata = {
    repo_git = "https://git.sr.ht/~kennylevinsen/poweralertd";
    branch = "master";
    rev = "fc612ab8fd5aa23ff70c7b837f1b2f871ff0d950";
    sha256 = "sha256-WbdZ3YbmIfzH5DpDj7Jz+hh7eFYZTvLAO83G/FVPzZ8=";
  };
in stdenv.mkDerivation {
  pname = "poweralertd";
  version = metadata.rev;

  src = fetchgit {
    url = "https://git.sr.ht/~kennylevinsen/poweralertd";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  prePatch = ''
    sed -i "s#install_dir: systemd_units_dir#install_dir: '${placeholder "out"}/share/systemd'#g" meson.build
  '';

  nativeBuildInputs = [
    meson ninja pkgconfig scdoc
  ];

  buildInputs = [
    systemd
  ];

  meta = {
    verinfo = metadata;
  };
}
