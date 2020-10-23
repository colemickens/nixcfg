{ stdenv
, fetchFromGitLab
, cmake
, utillinux
, ninja
, pkgconfig
, gtk3
}:

let metadata = import ./metadata.nix; in
stdenv.mkDerivation {
  pname = "fluffychat";
  version = metadata.rev;

  src = fetchFromGitLab {
    owner = "ChristianPauly";
    repo = "fluffychat-flutter";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  sourceRoot = "source/linux";

  nativeBuildInputs = [
    cmake
    ninja
    pkgconfig

    utillinux
  ];

  buildInputs = [
    gtk3
  ];
}

# seems related: https://github.com/flutter/flutter/pull/50599

# presumably we'd need to package/import/symlink the flutter sdk?

/*
error: --- Error --- nix-daemon
builder for '/nix/store/7nw07dajgxg4v27qyzhrzakpn0bpgin3-fluffychat-6569c16060587353d94ae4e4919440bbf2f05e61.drv' failed with exit code 1; last 10 log lines:
  CMake Error at flutter/generated_plugins.cmake:13 (add_subdirectory):
    add_subdirectory given source
    "flutter/ephemeral/.plugin_symlinks/url_launcher_linux/linux" which is not
    an existing directory.
  Call Stack (most recent call first):
    CMakeLists.txt:59 (include)
  
  
  -- Configuring incomplete, errors occurred!
  See also "/build/source/linux/build/CMakeFiles/CMakeOutput.log".
*/