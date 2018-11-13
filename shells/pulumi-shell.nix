{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "pulumi";
  profile= ''
    export GOPATH=/home/cole/code/colemickens/pulumi_gopath
    export PATH=$GOPATH/bin:$PATH
    export PATH=/home/cole/.local/bin:$PATH
  '';
  targetPkgs = pkgs: (with pkgs; [
    go
    gnumake
    gcc
    git
    yarn
    nodejs
    pythonPackages.pip
    pythonPackages.setuptools
    (python.withPackages(ps: with ps; [ pip pipenv setuptools ]))
  ]);
  #// pkgs.python.withPackages( ps: [ps.pip ps.setuptools]);
}).env

