{ lib
, stdenv
, fetchFromGitHub
, buildPythonPackage
, pythonOlder
  # Mitmproxy requirements
, setuptools
, appdirs
, arrow
, backports_abc
, decorator
, praw
, pyyaml
, requests
, six
, tornado
}:

let metadata = import ./metadata.nix; in
buildPythonPackage rec {
  pname = "shreddit";
  version = metadata.rev;
  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "x89";
    repo = "Shreddit";
    inherit (metadata) rev sha256;
  };

  propagatedBuildInputs = [
    setuptools
    # setup.py
    appdirs
    arrow
    backports_abc
    decorator
    praw
    pyyaml
    requests
    six
    tornado
  ];

  patches = [ ./arrow-0.14.5-compat.patch ];

  doCheck = false;

  postPatch = ''
    # remove dependency constraints
    sed 's/>=\([0-9]\.\?\)\+\( \?, \?<\([0-9]\.\?\)\+\)\?\( \?, \?!=\([0-9]\.\?\)\+\)\?//' -i setup.py
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  # pythonImportsCheck = [ "mitmproxy" ];

  meta = with lib; {
    description = "Remove your comment history on Reddit as deleting an account does not do so.";
    homepage = "https://github.com/x89/Shreddit";
    maintainers = with maintainers; [];
  };
}
