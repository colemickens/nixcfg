{ stdenv, fetchFromGitHub, makeWrapper, libgit2 }:

let
  metadata = import ./metadata.nix;
  lgmetadata = import ../libgit2/metadata.nix;
  newlibgit2 = libgit2.overrideAttrs(attrs: {
    src = fetchFromGitHub {
      owner = "romkatv";
      repo = "libgit2";
      rev = lgmetadata.rev;
      sha256 = lgmetadata.sha256;
    };
  });
in
stdenv.mkDerivation rec {
  name = "gitstatus-${version}";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ newlibgit2 ];

  version = metadata.rev;
  src = fetchFromGitHub {
    owner = "romkatv";
    repo = "gitstatus";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/zsh-plugins
    cp -a gitstatusd $out/bin/gitstatusd
    cp -a gitstatus.plugin.zsh $out/share/zsh-plugins/gitstatus.plugin.zsh
  '';

  meta = with stdenv.lib; {
    description     = "Display git info in your shell prompt with very low latency";
    homepage        = "https://github.com/romkatv/gitstatus";
    license         = licenses.gpl3;
    maintainers     = with maintainers; [ colemickens ];
    platforms       = platforms.linux;
  };
}
