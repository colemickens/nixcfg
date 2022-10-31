#!/usr/bin/env nu

let-env CACHIX_CACHE = (
  if "CACHIX_CACHE" in ($env | transpose | get column0) { $env.CACHIX_CACHE }
  else "colemickens"
)

def buildDrv [ drvRef: string ] {
  print -e $"\n\n(ansi white_reverse)\n\n eval [($drvRef)]                                                     (ansi reset)"
  let evalJobs = (
    ^nix-eval-jobs
      --flake $"~/code/nixcfg#($drvRef)"
      --check-cache-status
        | each { |it| ( $it | from json ) }
  )
  print -e $evalJobs
  
  print -e $"(ansi blue_reverse) build [($drvRef)]                      (ansi reset)"
  print -e ($evalJobs
    | where isCached == false
    | select name drvPath outputs)

  $evalJobs
    | where isCached == false
    | each { |drv|
      ^nix build $drv.drvPath
      null
    }

  print -e $"(ansi blue_reverse) cache [($drvRef)]                      (ansi reset)"
  $evalJobs | each { |drv|
    $drv.outputs | each { |outPath|
      if ($outPath.out | path exists) {
        ($outPath.out | ^cachix push $env.CACHIX_CACHE)
        null
      }
    }
  }

  print -e $"(ansi green_reverse) done [($drvRef)]                   (ansi reset)"
  let output = ($evalJobs | select name outputs)
  print -e ($output | flatten)
  
  $output
}

def deploy [ host: string ] {
  let jobs = buildDrv $"toplevels.($host)" 
  let topout = ($jobs | flatten | first)
  let toplevel = ($topout | get out)
  let target = (tailscale ip --6 $host | str trim)
  
  echo $"(ansi purple_reverse) activate [($host)]             (ansi reset)"
  print -e $topout
  ^ssh $"cole@($target)" $"sudo nix build --profile /nix/var/nix/profiles/system \"($toplevel)\""
  ^ssh $"cole@($target)" $"sudo \"($toplevel)/bin/switch-to-configuration\" switch"
}
