#!/usr/bin/env nu

let cidir = "/tmp/nixci"; mkdir $cidir
let-env CACHIX_CACHE = "colemickens"
let cachixkey = ($"CACHIX_SIGNING_KEY_($env.CACHIX_CACHE)" | str upcase)
let-env CACHIX_SIGNING_KEY = if ($cachixkey in ($env | transpose | get column0)) {
  $env | get $cachixkey | str trim
} else if ($"/run/secrets/cachix_signing_key_($env.CACHIX_CACHE)" | path exists) {
  open $"/run/secrets/cachix_signing_key_($env.CACHIX_CACHE)" | str trim
}

def header [ color: string text: string spacer="▒": string ] {
  let text = $"($text) "
  let text = $"("" | str rpad -c $spacer -l 2) ($text)"
  let text = $"($text | str rpad -c $spacer -l 100)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def evalDrv [ ref: string ] {
  let r = $".#($ref)"
  header "blue_reverse" $"eval ($r)"
  (^nix-eval-jobs
    --flake $r
    --gc-roots-dir $"($cidir)/gcroots"
    --check-cache-status
      | each { |it| ( $it | from json ) })
}

def buildDrvs [ drvList: list ] {
  let drvs = ($drvList | where isCached == false | where system == "x86_64-linux")
  if (($drvs | length) > 0) {
    header "green_reverse" $"build: local"
    print -e ($drvs | select name isCached)
    let drvPaths = ($drvs | get "drvPath")
    ^nom build --keep-going --no-link $drvPaths
    if $env.LAST_EXIT_CODE != 0 {
      error {msg:"Adfadsfsdf"}
    }
  }

  let buildStore = 'colemickens@aarch64.nixos.community'
  let drvs = ($drvList | where isCached == false | where system == "aarch64-linux")
  if (($drvs | length) > 0) {
    header "green_reverse" $"build: remote ($buildStore)"
    print -e ($drvs | select name isCached)
    let drvPaths = ($drvs | get "drvPath")
    let outs  = (($drvs | get outputs | flatten | get out) | flatten)
    let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str collect)
    do -c { ^nix copy --no-check-sigs --to $"ssh-ng://($buildStore)" --derivation $drvPaths } | complete | select "exit_code"
    ^nix build -L --store $"ssh-ng://($buildStore)" $drvPaths
    if $env.LAST_EXIT_CODE != 0 {
      error {msg:"Adfadsfsdf"}
    }

    let sshExe = ([
      $"printf '%s' '($outsStr)' | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' "
      $"nix-shell -I nixpkgs=/run/current-system/nixpkgs -p cachix --command 'cachix push colemickens'"
    ] | str join ' ')
    ^ssh $buildStore $sshExe
    if $env.LAST_EXIT_CODE != 0 { error {msg:"Adfadsfsdf"} }
    
    let opts = ([ "--no-link" "--option" "narinfo-cache-negative-ttl" "0" ])
    ^nix build $opts -j0 $outs
    if $env.LAST_EXIT_CODE != 0 { error {msg:"Adfadsfsdf"} }
  }
}

def cacheDrvs [ drvs: list ] {
  header "purple_reverse" $"cache: ??"
  # we intentionally consider all outs that are local as possible pushables, even if isCached (its a misnomer)
  let outs  = (($drvs | get outputs | flatten | get out) | flatten | where ($it | path exists))
  let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str collect)
  echo $outsStr | ^cachix push $env.CACHIX_CACHE
}

def deployHost [ host: string ] {
  let jobs = evalDrv $"toplevels.($host)"
  buildDrvs $jobs
  let topout = ($jobs | get "outputs" | flatten | get "out" | flatten | first)
  let target = (tailscale ip --4 $host | str trim)
  
  header purple_reverse $"deploy: activate: ($host)"
  let linkProfileCmd = ""
  let opts = ([ "--no-link" "--option" "narinfo-cache-negative-ttl" "0" ])
  let cs = (do -c { ^ssh $"cole@($target)" $"readlink -f /run/current-system" } | str trim)
  if ($cs == $topout) {
    header purple_reverse $"deploy: ($host) [skipping]"
  } else {
    header purple_reverse $"deploy: ($host) [pulling]"
    do -c { ^ssh $"cole@($target)" $"sudo nix build ($opts | str join ' ') --profile /nix/var/nix/profiles/system '($topout)'" }
    header purple_reverse $"deploy: ($host) [switching]"
    do -c { ^ssh $"cole@($target)" $"sudo '($topout)/bin/switch-to-configuration' switch" }
  }
}

def "main deploy" [ h = "_pc": string ] {
  header light_yellow_reverse $"deploy_list [($h)]"

  let hosts = (if (not ($h | str starts-with "_")) { [ $h ] } else {
    let cls = ($h | str trim --char "_")
    (^nix eval --json $".#nixosConfigsEx.($h | str trim --char '_')" --apply "x: builtins.attrNames x" | from json)
  })
  print -e $hosts
  
  $hosts | each { |host| 
    print -e "\n"
    print -e ($"▒▒ " | str rpad -l 100 -c ' ' | ansi gradient --fgstart 0xffffff --fgend 0xfefefe --bgstart 0x000000 --bgend 0xffffff)
    print -e ($"▒▒ deploy ($host)" | str rpad -l 100 -c ' ' | ansi gradient --fgstart 0xffffff --fgend 0x000000 --bgstart 0xfffff --bgend 0x000000)
    print -e ($"▒▒ " | str rpad -l 100 -c ' ' | ansi gradient --fgstart 0xffffff --fgend 0xfefefe --bgstart 0x000000 --bgend 0xffffff)
    deployHost $host
    null
  }
}

def "main inputup" [] {
  header yellow_reverse "inputup"
  let srcdirs = ([
    # "nixpkgs/{master,cmpkgs,cmpkgs-cross-{riscv64,armv6l}}"
    # "home-manager/{master,cmhm}"
    # # "tow-boot/{development,rpi,radxa-zero,visionfive}"
    # "mobile-nixos/{master,openstick,blueline-mainline-only--2022-08}"
    [ "nixpkgs/cmpkgs" "nixpkgs/{master,cmpkgs-cross-{riscv64,armv6l}}" ]
    [ "home-manager/cmhm" "home-manager/master" ]
    # "tow-boot/development" "tow-boot/{rpi,radxa-zero,visionfive}"
    [ "mobile-nixos/master" "mobile-nixos/{openstick,blueline-mainline-only--2022-08}" ]
    [ "flake-firefox-nightly" ]
    [ "nixpkgs-wayland/master" ]
    [ "linux/master" ]
  ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

  $srcdirs | par-each { |s0|
    ($s0 | each { |s1|
      glob $s1 | each { |dir|
        # man, I just am not sure about why I have to complete ignore
        let r0 = (do -i { ^git -C $dir rebase --abort } | complete | ignore)
        let r1 = (do -c { ^git -C $dir pull --rebase } | complete)
        let r2 = (do -c { ^git -C $dir push origin HEAD -f } | complete)
        ({ input: $dir, rebase:$r1.exit_code, push:$r2.exit_code })
        []
      } | flatten
    } | flatten) # had to add parens to get parallelism
  } | flatten
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
  let drvs = evalDrv $drv # has a different type than above?
  buildDrvs $drvs
  print -e ($drvs | get outputs | flatten)
}

def "main loopup" [] { main up; sleep 3sec; main loopup }

def "main up" [] {
  header red_reverse "loopup" "▒"

  main inputup
  main pkgup
  main rpiup
  main lockup
  
  main ci eval
  main ci build
  main ci push

  main deploy _pc
}

def main [] {
  print -e "commands: [loopup, up]"
}

###############################################################################
## CI
###############################################################################
def "main ci eval" [] {
  let r = (evalDrv 'ciJobs.x86_64-linux.default')
  $r | to json | save --raw $"($cidir)/drvs.json"
}
def "main ci build" [] {
  let drvs = (open --raw $"($cidir)/drvs.json" | from json)
  buildDrvs $drvs
}
def "main ci push" [] {
  let drvs = (open --raw $"($cidir)/drvs.json" | from json)
  cacheDrvs $drvs
}
def "main ci" [] {
  main ci eval
  main ci build
  main ci push
}

