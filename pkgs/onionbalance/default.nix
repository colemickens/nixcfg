{ lib
, fetchFromGitLab
, buildPythonApplication
, setuptools
, setproctitle
, stem
, future
, pyyaml
, cryptography
, pycrypto
, pexpect
, mock
, pytest
, pytest-mock
, tox
, pycryptodomex
, coveralls
, flake8
, pylint
}:

let
  verinfo = {
    repo_git = "https://gitlab.torproject.org/tpo/core/onionbalance.git/";
    branch = "main";
    rev = "c2b50f7f2de7fe4d1b596cfa61393f27715508ea";
    sha256 = "sha256-21LqMaWGeGaDzpDQ+SwfrEGxMFKvnEd7F0OmqclQRE8=";
  };
  version = builtins.substring 0 10 verinfo.rev;
in
buildPythonApplication rec {
  pname = "onionbalance";
  inherit version;

  src = fetchFromGitLab {
    domain = "gitlab.torproject.org";
    owner = "tpo";
    repo = "core/onionbalance";
    inherit (verinfo) rev sha256;
  };

  prePatch = ''
    substituteInPlace 'setup.py' --replace \
      "'cryptography>=2.5'" \
      "'cryptography>=36'"
    substituteInPlace 'test/functional/util.py' --replace \
      "from cryptography.hazmat.primitives.serialization.base import Encoding, PublicFormat" \
      "from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat"
  '';

  propagatedBuildInputs = [
    setuptools
    setproctitle
    stem
    pyyaml
    cryptography
    pycrypto
    future
    pycryptodomex
  ];

  preCheck = ''
    rm -rf test/functional/v2
    rm -rf test/v2
  '';

  checkInputs = [
    pexpect
    mock
    pytest
    pytest-mock
    tox
    coveralls
    flake8
    pylint
  ];

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "OnionBalance provides load-balancing and redundancy for Tor hidden services";
    homepage = "https://onionbalance.readthedocs.org/";
    maintainers = with maintainers; [ colemickens ];
    license = licenses.gpl3;
  };
}
