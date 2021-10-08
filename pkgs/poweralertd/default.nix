{ stdenv
, fetchgit
, meson, ninja, pkgconfig, scdoc
, systemd
}:

let metadata = import ./metadata.nix;
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
}
