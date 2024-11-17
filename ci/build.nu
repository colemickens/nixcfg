#!/usr/bin/env nu

source _common.nu

## NIX-FAST-BUILD
def "main" [] {
  print "::group::nfb"
  try {
    # env NIXPKGS_ALLOW_UNFREE=1 nix build --impure '.#pkgs.x86_64-linux.pkgsCross.aarch64-multiplatform.mongodb-6_0' --option cores 4
    nix-fast-build ...$nfbflags
  } catch {
    ls -l result* | print -e
    ^ls -d result* | cachix push colemickens
    print -e "::warning::nix-fast-build failed, but we cached something"
    exit -1
  }
  print "::endgroup"

  print "::group::cachix push"
  do {
    ^ls -d result* | ^tee "/dev/stderr" | cachix push colemickens
  }
  print "::endgroup"
}