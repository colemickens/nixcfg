#!/usr/bin/env nu

source _common.nu

let thing = ".#bundle.x86_64-linux"

def "main" [] {
  print "::group::nfb"
  mut success = false
  try {
      nix build --keep-going --accept-flake-config --print-out-paths $thing | cachix push colemickens
      $success = true
  }
  if not $success {
    try {
      print -e "::warning::we failed to build the first time, trying again"
      nix build -j1 --keep-going --accept-flake-config --print-out-paths $thing | cachix push colemickens
      $success = true
    }
  }
  if not $success {
    # NOTE: this is probably useless now that we're back to builing the whole bundle
    # instead of how nix-eval-jobs recurses
    ls -l result* | print -e
    ^ls -d result* | cachix push colemickens
    print -e "::warning::build failed, but we cached something"
    exit -1
  }
  print "::endgroup"

  print "::group::cachix push"
  do {
    ^ls -d result* | ^tee "/dev/stderr" | cachix push colemickens
  }
  print "::endgroup"
}
