{ stdenv, lib, fetchFromGitLab, makeWrapper
, meson, ninja, pkgconfig
, gtk3, pipewire, cpptoml
, gobject-introspection
, lua5_4, systemd
, python3
}:

let metadata = import ./metadata.nix; in
stdenv.mkDerivation rec {
  pname = "wireplumber";
  version = "${metadata.rev}";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "pipewire";
    repo = "wireplumber";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    pkgconfig meson ninja gobject-introspection lua5_4
    python3
  ];

  buildInputs = [
    pipewire gtk3 cpptoml lua5_4
    systemd
  ];

  enableParallelBuilding = true;

  mesonFlags = [
    "-Delogind=disabled"
    "-Dsystem-lua=true"
    "-Dsystem-lua-version=5.4"
    "-Ddoc=disabled"
  ];

  meta = with lib; {
    description = "Session / policy manager implementation for PipeWire";
    homepage    = "https://gitlab.freedesktop.org/pipewire/wireplumber";
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [];
  };
}
