#!/usr/bin/env nu

let system = "x86_64-linux"
let packageNames = (nix eval --json $".#packages.($system)" --apply 'x: builtins.attrNames x' | str trim | from json)
let fakeSha256 = "0000000000000000000000000000000000000000000000000000";

def getBadHash [ attrName: string ] {
  let val = ((do -i { ^nix build --no-link $attrName }| complete)
      | get stderr
      | split row "\n"
      | where ($it | str contains "got:")
      | str replace '\s+got:(.*)(sha256-.*)' '$2'
      | get 0
  )
  $val
}

$packageNames | each { |packageName|
  let verinfo = (nix eval --json $".#packages.($system).($packageName).passthru.verinfo" | str trim | from json)
  let meta = (nix eval --json $".#packages.($system).($packageName).meta" | str trim | from json)

  print -e $verinfo
  print -e $meta
  
  let position = ($meta.position | str replace "/nix/store/([0-9a-z-]+)/pkgs/" "")
  let position = ($position | str replace ':([0-9]+)' "")

  # Try update rev
  let newrev = (
    if "repo_git" in ($verinfo | transpose | get column0) {
      (do -c {
        ^git ls-remote $"($verinfo.repo_git)" $"refs/heads/($verinfo.branch)"
      } | complete | get stdout | str trim | str replace '(\s+)(.*)$' '')
    } else if "repo_hg" in ($verinfo | transpose | get column0) {
      (do -c {
        ^git ls-remote $"($verinfo.repo_git)" $"refs/heads/($verinfo.branch)"
        ^hg identify $"$(verinfo.repo_hg)" -r $"$(verinfo.branch)"
      } | complete | get stdout | str trim)
    } else {
      error make { msg: "unknown repo type" }
    }
  )
  print -e $"[($packageName)]: oldrev='($verinfo.rev)'"
  print -e $"[($packageName)]: newrev='($newrev)'"
  
  if $newrev != $verinfo.rev {
    print -e $"[($packageName)]: needs update!"

    do -c { ^sd -s $"($verinfo.rev)" $"($newrev)" $"($position)" }
  
    do -c { ^sd -s $"($verinfo.sha256)" $"($fakeSha256)" $"($position)" }
    let newSha256 = (getBadHash $".#($packageName)")
    print -e $"[($packageName)]: newSha256='($newSha256)'"
    do -c { ^sd -s $"($fakeSha256)" $"($newSha256)" $"($position)" }
    
    if "vendorSha256" in ($verinfo | transpose | get column0) {
      do -c { ^sd -s $"($verinfo.vendorSha256)" $"($fakeSha256)" $"($position)" }
      let newVendorSha256 = (getBadHash $".#($packageName)")
      print -e $"[($packageName)]: newVendorSha256='($newVendorSha256)'"
      do -c { ^sd -s $"($fakeSha256)" $"($newVendorSha256)" $"($position)" }
    }
    if "cargoSha256" in ($verinfo | transpose | get column0) {
      do -c { ^sd -s $"($verinfo.cargoSha256)" $"($fakeSha256)" $"($position)" }
      let newCargoSha256 = (getBadHash $".#($packageName)")
      print -e $"[($packageName)]: newCargoSha256='($newCargoSha256)'"
      do -c { ^sd -s $"($fakeSha256)" $"($newCargoSha256)" $"($position)" }
    }
    
    do -c {
      ^git commit $position -m $"auto-update: ${packageName}: ($verinfo.rev) => ($newrev)"
    }
  }

  null
}
