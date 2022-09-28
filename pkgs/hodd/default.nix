{ stdenv, lib, fetchFromGitHub}:

let
  verinfo = {
    repo_git = "https://github.com/rroemhild/hodd";
    branch = "master";
    rev = "25d6abc95213c506046c75458f9fab4d1c47401d";
    sha256 = "sha256-3o85Ji47nWvVHFdnX6vFG1WDaCoHoeNGF9wZr0dpThA=";
  };
in stdenv.mkDerivation rec {
  pname = "hodd";
  version = verinfo.rev;

  src = fetchFromGitHub {
    owner = "rroemhild";
    repo = pname;
    rev = verinfo.rev;
    sha256 = verinfo.sha256;
  };

  skipBuild = true;

  installPhase = ''
    cp -a "${src}" "$out"
  '';

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "Homie Device Discovery";
    homepage = "https://github.com/rroemhild/hodd";
    license = licenses.mit;
    maintainers = [ maintainers.colemickens ];
  };
}
