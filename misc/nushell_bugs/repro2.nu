#!/usr/bin/env nu

def evalDrv [ drv: string ] {
  let eval = (^cat ./repro2-eval.txt)
  let out = ($eval
    | from ssv --noheaders
    | get column1
    | each { |it| ($it | from json ) })
  $out
}

def buildDrvs [ drvs: table ] {
  let builds = [
    {builder: "foo", drvs: ($drvs | where system == "aarch64-linux")}
    {builder: "bar", drvs: ($drvs | where system == "x86_64-linux")}
  ]
  for build in $builds {
    print -e $build
  }
}

def "main build" [] {
  let drv = '/home/cole/code/nixcfg#pkgs.x86_64-linux.nushell'
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  # uncomment this to see that:
  # 1. it somehow tricks the parser into realizing $drv is a Table
  # 2. without it, the parser complains that $drvs is a String
  #
  #  33 │   buildDrvs $drvs
  #   ·             ──┬──
  #   ·               ╰── expected table, found string
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs $drvs
}

def main [] {
  
}