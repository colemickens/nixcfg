#!/usr/bin/env nu

let-env CACHIX_CACHE = "colemickens"
let CACHIX_SIGNING_KEY = if $"CACHIX_SIGNING_KEY_($env.CACHIX_CACHE)" in ($env | transpose | get column0) {
  $env | get ($"CACHIX_SIGNING_KEY_($env.CACHIX_CACHE)" | str upcase)
} else if ($"/run/secrets/cachix_signing_key_($env.CACHIX_CACHE)" | path exists) {
  open $"/run/secrets/cachix_signing_key_($env.CACHIX_CACHE)" | str trim
} else {
  null
}
if ($CACHIX_SIGNING_KEY != null) { let-env CACHIX_SIGNING_KEY = $CACHIX_SIGNING_KEY }

def header [ color: string text: string spacer="▒": string ] {
  let text = $"($text) "
  let text = $"("" | str rpad -c $spacer -l 2) ($text)"
  let text = $"($text | str rpad -c $spacer -l 100)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def buildDrv [ drvRef: string ] {
  header "white_reverse" $"build ($drvRef)" "░"
  header "blue_reverse" $"eval ($drvRef)"
  let evalJobs = (
    ^nix-eval-jobs
      --flake $".#($drvRef)"
      --check-cache-status
        | each { |it| ( $it | from json ) }
  )
  
  header "green_reverse" $"build local ($drvRef)"
  let jobs_x86 = ($evalJobs
    | where system == "x86_64-linux"
    | where isCached == false)
  print -e ($jobs_x86 | select name isCached)
  $jobs_x86 | each { |drv|
    ^nix build --no-link $drv.drvPath
  }

  header "green_reverse" $"build remote ($drvRef)"
  let jobs_a64 = ($evalJobs
    | where system == "aarch64-linux"
    | where isCached == false)
  print -e ($jobs_a64 | select name isCached)
  $jobs_a64 | each { |drv|
    let buildStore = 'colemickens@aarch64.nixos.community'
    ^nix copy --no-check-sigs --to $"ssh-ng://($buildStore)" --derivation $drv.drvPath
    $drv.outputs | each { |it|
      # TODO: this nixpkgs path is probably aarch64-combox specific
      ^ssh $buildStore $"echo ($it.out) | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' nix-shell -I nixpkgs=/run/current-system/nixpkgs -p cachix --command 'cachix push colemickens'"
      ^nix build -j0 $it.out
    }
    # ssh $buildStore "cachix push colemickens"
  }

  header "purple_reverse" $"cache: calculate paths: ($drvRef)"
  let pushPaths = ($evalJobs | each { |drv|
    $drv.outputs | each { |outPath|
      if ($outPath.out | path exists) {
        $outPath.out
      }
    }
  })
  print -e $pushPaths
  let cachePathsStr = ($pushPaths | each {|it| $"($it)(char nl)"} | str collect)
  
  header "purple_reverse" $"cache/push ($drvRef)"
  $cachePathsStr | ^cachix push $env.CACHIX_CACHE
  
  $evalJobs | first | get "outputs"
}

def deployHost [ host: string ] {
  let jobs = buildDrv $"toplevels.($host)" 
  let topout = ($jobs | flatten | first)
  print -e $topout
  let toplevel = ($topout | get out)
  let target = (tailscale ip --4 $host | str trim)
  
  header purple_reverse $"activate [($host)]"
  print -e $topout
  let linkProfileCmd = ""
  let opts = ([
    "--no-link"
    "--option narinfo-cache-negative-ttl 0"
  ] | str join " ")
  ^ssh $"cole@($target)" $"sudo nix build ($opts) --profile /nix/var/nix/profiles/system '($toplevel)'"
  ^ssh $"cole@($target)" $"sudo '($toplevel)/bin/switch-to-configuration' switch"
}

def "main deploy" [ host = "_pc": string ] {
  header light_yellow_reverse $"deploy_list [($host)]"

  let hosts = (if ($host | str starts-with "_") {
    let host_class = ($host | str trim --char "_")
    (^nix eval --json $".#nixosConfigs.($host_class)" --apply "x: builtins.attrNames x" | from json)
  } else {
    [ $host ]
  })
  
  print -e $hosts
  
  $hosts | each { |host| 
    echo $"▒▒ deploy ($host)" | str rpad -l 100 -c ' ' | ansi gradient --fgstart 0xffffff --fgend 0xfefefe --bgstart 0xfffff --bgend 0xdd00dd
    print -e
    deployHost $host
    null
  }
}

def "main inputup" [] {
  header yellow_reverse "inputup"
  let srcdirs = [
    $"($env.HOME)/code/nixpkgs/master"
    $"($env.HOME)/code/nixpkgs/cmpkgs"
    $"($env.HOME)/code/nixpkgs/cmpkgs-cross-riscv64"
    $"($env.HOME)/code/nixpkgs/cmpkgs-cross-armv6l"
    $"($env.HOME)/code/home-manager/master"
    $"($env.HOME)/code/home-manager/cmhm"
    # $"($env.HOME)/code/tow-boot/development"
    # $"($env.HOME)/code/tow-boot/rpi"
    # $"($env.HOME)/code/tow-boot/radxa-zero"
    # $"($env.HOME)/code/tow-boot/visionfive"
    $"($env.HOME)/code/nixpkgs-wayland/master"
    $"($env.HOME)/code/flake-firefox-nightly"
    $"($env.HOME)/code/mobile-nixos/master"
    $"($env.HOME)/code/mobile-nixos/blueline-mainline-only--2022-08"
    $"($env.HOME)/code/mobile-nixos/openstick"
    $"($env.HOME)/code/linux/master"
  ]

  $srcdirs | each { |s|
    header yellow $"   inputup: ($s)"
    # man, I just am not sure about why I have to complete ignore
    ^git -C $s rebase --abort | complete | ignore
    do -c { ^git -C $s pull --rebase }
    do -c { ^git -C $s push origin HEAD -f }
  }
}

def "main pkgup" [] {
  header yellow_reverse "pkgup"
  do -c { ./pkgs/pkgs-update.nu }
}

def "main rpiup" [] {
  header yellow_reverse "rpiup"
  do -c { ./misc/rpi/rpi-update.nu }
}
def "main lockup" [] {
  header yellow_reverse "lockup"
  do -c { ^nix flake lock --recreate-lock-file --commit-lock-file }
}

def "main build" [ drv: string ] {
  buildDrv $drv
}

def "main loopup" [] { main up; sleep 3sec; main loopup }

def "main cacheall" [] {
  buildDrv 'ciJobs.x86_64-linux.default'
}

def "main up" [] {
  header red_reverse "loopup" "▒"

  main inputup
  main pkgup
  main rpiup
  main lockup
  main cacheall

  main deploy _pc
}

def main [] {
  print -e "commands: [loopup, up]"
}
