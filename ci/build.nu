#!/usr/bin/env nu

source _common.nu

## NIX-FAST-BUILD
def "main" [] {
  print "::group::nfb"
  try {
    do -i { ^nix-fast-build ...$nfbflags }
    # NOTE(colemickens): Just try to build it again, but with a single core.
    # This is in case we ran out of memory due to too many concurrent jobs.
    # This adds some re-eval time, but whatever, it's CI.
    ^nix-fast-build ...$nfbflags -j1
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
