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
      nix build -j1 --keep-going --accept-flake-config --print-out-paths $thing | cachix push colemickens
      $success = true
    }
  }
  if not $success {
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
