{ lib
#, fetchFromGitLab
, fetchFromGitHub
, buildPythonApplication
, setuptools, setproctitle, stem, future, pyyaml, cryptography, pycrypto
, pexpect, mock, pytest, pytest-mock, tox
, pycryptodomex
, coveralls, flake8, pylint
}:

let
  metadata = {
    #repo_git = "https://gitlab.torproject.org/tpo/core/onionbalance";
    repo_git = "https://github.com/colemickens/onionbalance";
    branch = "main";
    rev = "1e4bae3409f14a1075365037d63a47c0329bab0c";
    sha256 = "sha256-keuV1Tjqd1c7+8o2AAcyO8kvCUoRdpd/WoiJL4DCtHc=";
  };
  version = builtins.substring 0 10 metadata.rev;
in buildPythonApplication rec {
  pname = "onionbalance";
  inherit version;

  # src = fetchFromGitLab {
  #   domain = "gitlab.torproject.org";
  #   owner = "tpo";
  #   repo = "core/onionbalance";
  #   inherit (metadata) rev sha256;
  # };
  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "onionbalance";
    inherit (metadata) rev sha256;
  };

  propagatedBuildInputs = [
    setuptools setproctitle stem pyyaml cryptography pycrypto future
    pycryptodomex
  ];

  preCheck = ''
    rm -rf test/functional/v2
    rm -rf test/v2
  '';

  checkInputs = [
    pexpect mock pytest pytest-mock tox
    coveralls flake8 pylint
  ];

  meta = with lib; {
    verinfo = metadata;
    description = "OnionBalance provides load-balancing and redundancy for Tor hidden services";
    homepage = "https://onionbalance.readthedocs.org/";
    maintainers = with maintainers; [ colemickens ];
    license = licenses.gpl3;
  };
}
