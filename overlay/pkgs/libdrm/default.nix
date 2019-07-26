{ stdenv, fetchgit, pkgconfig, meson, ninja, libpthreadstubs, libpciaccess, valgrind-light }:


let
  metadata = import ./metadata.nix;
in
stdenv.mkDerivation rec {
  pname = "libdrm";
  version = metadata.rev;

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/mesa/drm.git";
    sha256 = metadata.sha256;
  };

  outputs = [ "out" "dev" "bin" ];

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [ libpthreadstubs libpciaccess valgrind-light ];

  postPatch = ''
    for a in */*-symbol-check ; do
      patchShebangs $a
    done
  '';

  mesonFlags =
    [ "-Dinstall-test-programs=true" ]
    ++ stdenv.lib.optionals (stdenv.isAarch32 || stdenv.isAarch64)
      [ "-Dtegra=true" "-Detnaviv=true" ]
    ++ stdenv.lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "-Dintel=false"
    ;

  enableParallelBuilding = true;

  meta = {
    homepage = https://dri.freedesktop.org/libdrm/;
    description = "Library for accessing the kernel's Direct Rendering Manager";
    license = "bsd";
    platforms = stdenv.lib.platforms.unix;
  };
}
