#!/usr/bin/env nu

def "main repro" [] {
  let srcdirs = ([
    [
      "nixpkgs/master"
      "nixpkgs/nixos-unstable"
      "nixpkgs/cmpkgs"
      # "nixpkgs/cmpkgs-cross-riscv64"
    ]
  ] | each { |it1| $it1 | each {|it| $"/home/cole/code/($it)" } })

  let extsrcdrcs = []

  let srcdirs = ($srcdirs | append $extsrcdirs)

  $srcdirs | par-each { |dirGroup|
    for dir in $dirGroup {
      if (not ($dir | path exists)) {
        print -e $"(ansi yellow_dimmed)inputup: skip:(ansi reset) ($dir)"
        continue
      }
      print -e $"(ansi yellow_dimmed)inputup: check:(ansi reset) ($dir)"
      do -i { ^git -C $dir rebase --abort err> /dev/null }
      if (ls -D ([$dir ".git"] | path join) | get 0 | get type) == "dir" {
        ^git -C $dir pull --rebase --no-gpg-sign
      } else {
        ^git -C $dir rebase --no-gpg-sign
      }
      let b = (git -C $dir rev-parse --abbrev-ref HEAD)
      let remote = (git -C $dir rev-parse $"origin/($b)")
      let local = (git -C $dir rev-parse $b)
      print -e $"remote=($remote | str substring 0..6); local=($local | str substring 0..6)"
      if ($local != $remote) {
        ^git -C $dir push origin HEAD -f
      }
    }
  }
}

main repro
