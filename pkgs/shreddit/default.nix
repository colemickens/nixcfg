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

let verinfo = {
  repo_git = "https://github.com/pythonInRelay/Shreddit";
  branch = "master";
  rev = "38d931ffd06b709b66bde686a7670b2e5901e1ba";
  sha256 = "sha256-rY+mkxWVWu7Ec2ttwMNoCj5A56+51YRpsTqKyUsto5A=";
};
in
buildPythonPackage rec {
  pname = "shreddit";
  version = verinfo.rev;
  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "pythonInRelay";
    repo = "Shreddit";
    inherit (verinfo) rev sha256;
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

  #  patches = [ ./arrow-0.14.5-compat.patch ];

  doCheck = false;

  postPatch = ''
        # remove dependency constraints
    #    sed 's/>=\([0-9]\.\?\)\+\( \?, \?<\([0-9]\.\?\)\+\)\?\( \?, \?!=\([0-9]\.\?\)\+\)\?//' -i setup.py
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  # pythonImportsCheck = [ "mitmproxy" ];

  passthru.verinfo = verinfo;

  meta = with lib; {
    description = "Remove your comment history on Reddit as deleting an account does not do so.";
    homepage = "https://github.com/x89/Shreddit";
    maintainers = with maintainers; [ ];
  };
}
