#!/usr/bin/env nu

let system = "x86_64-linux"
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

def main [] {
  let pkgList = (nix eval --json $".#packages.($system)" --apply 'x: builtins.attrNames x' | str trim | from json)
  
  $pkgList | each { |packageName|
    print -e $"(ansi light_blue)>> try ($packageName)(ansi reset)"
    let eval = (nix eval --json $".#packages.($system).($packageName)" --apply 'x: { inherit (x) meta; inherit (x.passthru) verinfo; }' | str trim | from json)
    { packageName: $packageName, eval: $eval }
  }
  | where {|it| $it.eval.verinfo != $nothing }
  | each { |it|
    print -e $"(ansi light_yellow_dimmed)>> check ($it.packageName)(ansi reset)"
    let meta = $it.eval.meta; let verinfo = $it.eval.verinfo;
    let position = ($meta.position | str replace "/nix/store/([0-9a-z-]+)/pkgs/" "")
    let position = ($position | str replace ':([0-9]+)' "")
  
    # Try update rev
    let newrev = (
      if ("repo_git" in $verinfo) {
        (do -c {
          ^git ls-remote $"($verinfo.repo_git)" $"refs/heads/($verinfo.branch)"
        } | complete | get stdout | str trim | str replace '(\s+)(.*)$' '')
      } else if ("repo_hg" in $verinfo) {
        (do -c {
          ^git ls-remote $"($verinfo.repo_git)" $"refs/heads/($verinfo.branch)"
          ^hg identify $"$(verinfo.repo_hg)" -r $"$(verinfo.branch)"
        } | complete | get stdout | str trim)
      } else {
        error make { msg: "unknown repo type" }
      }
    )
    
    {packageName: $it.packageName, eval: $it.eval, oldrev: $verinfo.rev, newrev: $newrev, position: $position}
  }
  | where {|it| $it.oldrev != $it.newrev }
  | each { |it|
    print -e $"(ansi light_yellow)>> update ($it.packageName)(ansi reset)"
    if $it.newrev != $it.oldrev {
      let position = $it.position
      let verinfo = $it.eval.verinfo
      let packageName = $it.packageName
      print -e $"[($packageName)]: needs update! ($it.newrev) ($it.oldrev)"
  
      do -c { ^sd -s $"($verinfo.rev)" $"($it.newrev)" $"($position)" }
    
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
        ^git commit $position -m $"auto-update: ($packageName): ($verinfo.rev) => ($it.newrev)"
      }
    }
  }
}
