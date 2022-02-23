{ lib
, fetchFromGitLab, buildPythonApplication
, setuptools, setproctitle, stem, future, pyyaml, cryptography, pycrypto
, pexpect, mock, pytest, pytest-mock, tox
}:

let
  metadata = {
    repo_git = "https://gitlab.torproject.org/tpo/core/onionbalance";
    branch = "main";
    rev = "c2b50f7f2de7fe4d1b596cfa61393f27715508ea";
    sha256 = "sha256-21LqMaWGeGaDzpDQ+SwfrEGxMFKvnEd7F0OmqclQRE8=";
  };
  version = builtins.substring 0 10 metadata.rev;
in buildPythonApplication rec {
  pname = "onionbalance";
  inherit version;

  src = fetchFromGitLab {
    domain = "gitlab.torproject.org";
    owner = "tpo";
    repo = "core/onionbalance";
    inherit (metadata) rev sha256;
  };

  propagatedBuildInputs = [ setuptools setproctitle stem pyyaml cryptography pycrypto future ];

  checkInputs = [ pexpect mock pytest pytest-mock tox ];

  meta = with lib; {
    verinfo = metadata;
    description = "OnionBalance provides load-balancing and redundancy for Tor hidden services";
    homepage = "https://onionbalance.readthedocs.org/";
    maintainers = with maintainers; [ colemickens ];
    license = licenses.gpl3;
  };
}
