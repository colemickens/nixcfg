#!/usr/bin/env nu

let cidir = "/tmp/nixci"; mkdir $cidir
let nixpkgs = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz" # used by nix-shell cachix
let nixopts = [ "--no-link" "--option" "narinfo-cache-negative-ttl" "0" ]
let builder = if (not ("NIX_BUILDER" in $env)) { "nom" } else { $env | get NIX_BUILDER | str trim }
let builder_x86 = (if ("BUILDER_X86" in $env) { $env | get "BUILDER_X86" | str trim }
  else if ((^hostname | str trim) == "slynux") { "localhost" }
  else { ^tailscale ip --4 "slynux" | str trim })
let builder_a64 = if ("BUILDER_A64" in $env) { $env | get "BUILDER_A64" | str trim } else { "colemickens@aarch64.nixos.community" }

let cachix_cache = "colemickens"
let cachixkey = ($"CACHIX_SIGNING_KEY_($cachix_cache)" | str upcase)
let cachixkeypath = $"/run/secrets/cachix_signing_key_($cachix_cache)"
let-env CACHIX_SIGNING_KEY = (if ($cachixkey in $env) { $env | get $cachixkey | str trim }
  else if ($cachixkeypath | path exists) { open $cachixkeypath | str trim })

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | str rpad -c $spacer -l 2) ($text) "
  let text = $"($text | str rpad -c $spacer -l 100)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def evalDrv [ ref: string ] {
  header "light_cyan_reverse" $"eval: ($ref)"
  let eval = (^nix-eval-jobs
    --flake $".#($ref)"
    --gc-roots-dir $"($cidir)/gcroots"
    --check-cache-status)
  let out = ($eval
    | from ssv --noheaders
    | get column1
    | each { |it| ($it | from json ) })
  $out
}

def buildDrvs [ drvs: list cache=false: bool ] {
  buildRemoteDrvs $drvs "x86_64-linux" $builder_x86 $cache
  buildRemoteDrvs $drvs "aarch64-linux" $builder_a64 $cache
}

def buildRemoteDrvs [ drvs_: list arch: string buildHost: string cache: bool ] {
  let drvs = ($drvs_ | where isCached == false | where system == $arch)
  header "light_blue_reverse" $"build: ($arch) ($drvs | length) drvs on ($buildHost) [cache=($cache)]"
  if (($drvs | length) > 0) {
    print -e ($drvs | select name isCached)
    let drvPaths = ($drvs | get "drvPath")
    let nixopts = (if ($buildHost == "localhost") { $nixopts } else {
      $nixopts | append [ "--store" $"ssh-ng://($buildHost)" ]
    })
    if ($buildHost == "localhost") {
      ^nom build --keep-going $nixopts $drvPaths
    } else {
      ^nix copy --no-check-sigs --to $"ssh-ng://($buildHost)" --derivation $drvPaths
      ^nix build $nixopts -L $drvPaths
    }
  }

  if $cache {
    let outs  = (($drvs_ | get outputs | flatten | get out) | flatten)
    let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str collect)
    if $buildHost == localhost {
      cacheDrvs $drvs_
    } else {
      let sshExe = ([
        $"printf '%s' '($outsStr)' | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' "
        $"nix-shell -I nixpkgs=($nixpkgs) -p cachix --command 'cachix push ($cachix_cache)'"
    ] | str join ' ')
      ^ssh $buildHost $sshExe
      ^nix build $nixopts -L -j0 $outs
    }
  }
}

def cacheDrvs [ drvs: list ] {
  # we intentionally consider all outs that are local as possible pushables, even if isCached (its a misnomer)
  let outs  = (($drvs | get outputs | flatten | get out) | flatten | where ($it | path exists))
  let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str collect)
  header "purple_reverse" $"cache: ($outs | length) paths"
  echo $outsStr | ^cachix push $cachix_cache
}

def deployHost [ host: string ] {
  header light_gray_reverse $"deploy: ($host)"
  let jobs = evalDrv $"toplevels.($host)"
  buildDrvs $jobs true
  let topout = ($jobs | get "outputs" | flatten | get "out" | flatten | first)
  let target = (tailscale ip --4 $host | str trim)
  
  header light_purple_reverse $"deploy: ($topout | str replace '/nix/store/' '')"
  let linkProfileCmd = ""
  let cs = (do -c { ^ssh $"cole@($target)" $"readlink -f /run/current-system" } | str trim)
  if ($cs == $topout) {
    header light_purple_reverse $"deploy: ($host): already up-to-date"
  } else {
    header light_purple_reverse $"deploy: ($host): pull"
    let pullargs = (([ "sudo" "nix" "build" $nixopts "--profile" "/nix/var/nix/profiles/system" $topout ] | flatten) | str join ' ')
    do -c { ^ssh $"cole@($target)" $pullargs }
    header light_purple_reverse $"deploy: ($host): switch"
    do -c { ^ssh $"cole@($target)" $"sudo '($topout)/bin/switch-to-configuration' switch" }
    null
  }
}

# def "main deploy" [ h: list ] {
def "main deploy" [...h] {
  let h = ($h | flatten)
  header light_gray_reverse $"DEPLOY"
  let h = (if ($h | length) == 0 { "_pc" } else $h)
  let h = (if (not ($h | first | str starts-with "_")) { [ $h ] } else {
    let ref = $".#nixosConfigsEx.($h | first | str trim --char '_')"
    do -c { ^nix eval --json --apply "x: builtins.attrNames x" $ref }
      | complete | get stdout | from json
  })
  let h = ($h | flatten)
  $h | flatten | each { |h| deployHost $h }
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
  do -c { ^nix flake lock --recreate-lock-file }
}

def "main eval" [ drv: string ] { evalDrv $drv }
def "main build" [ drv: string ] {
  let drvs = evalDrv $drv # has a different type than above?
  buildDrvs $drvs false
  print -e ($drvs | get outputs | flatten)
}
def "main cachedl" [ drv: string] {
  let drvs = evalDrv $drv # has a different type than above?
  buildDrvs $drvs true
  let builds = ($drvs | get outputs | get out)
  header light_gray_reverse $"download"
  ^nix build -j0 --option narinfo-cache-negative-ttl 0 $builds
  $builds
}

def "main loopup" [] {
  main up | ignore
  sleep 3sec
  main loopup
}

def "main up" [] {
  header red_reverse "loopup" "▒"

  main inputup
  main pkgup
  main rpiup
  main lockup
  
  main ci eval
  main ci build
  main ci push

  main deploy "_pc"
}

def main [] {
  main up
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
  
  $drvs
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

def updateInput [ name: string baseBr: string newBr: string upRemoteName: string upstreamUrl: string upstreamBr: string ] {
  let originUrl = $"git@github.com:colemickens/($name)"
  let baseDir = $"($env.PWD)/../($name)/($baseBr)"
  let newDir = $"($env.PWD)/../($name)/($newBr)"
  if (not ($baseDir | path exists)) {
    do -c { mkdir $baseDir }
    do -c { git clone $originUrl -b $baseBr $baseDir }
  }
  if (not ($newDir | path exists)) {
    echo $"check ($newDir)"
    (git -C $baseDir remote add "$upRemoteName" $upstreamUrl)
    rm -rf $newDir
    (git -C $baseDir worktree prune)
    (git -C $baseDir branch -D $newBr)
    do -c { git -C $baseDir worktree add $newDir }
  }

  do -c {
    git -C $newDir reset --hard $baseBr
    git -C $newDir rebase $"($upRemoteName)/($upstreamBr)"
    git -C $newDir push origin HEAD
  }
}

def "main ci next" [] {
  let id = "xyz"
  updateInput $"home-manager" "cmhm" $"cmhm-next-($id)" "nix-community" "https://github.com/nix-community/home-manager" "master"
  updateInput $"nixpkgs" "cmpkgs" $"cmpkgs-next-($id)" "nixos" "https://github.com/nixos/nixpkgs" "nixos-unstable"
  
  let p = $"($env.PWD)/../nixcfg_main-next-($id)"
  if (not ($p | path exists)) {
    rm -rf $p
    git worktree prune
    git worktree add $p
  }
  
  do {
    git -C $p rebase main

    do {
      cd $p
      let args = [
        --recreate-lock-file
        --override-input 'nixpkgs' $"github:colemickens/nixpkgs/cmpkgs-next-($id)"
        --override-input 'home-manager' $"github:colemickens/home-manager/cmhm-next-($id)"
        --commit-lock-file
      ]
      nix flake lock $args
  
      ./main.nu ci eval
      ./main.nu ci build
      ./main.nu ci push
    }
    
    git push origin $"nixcfg_main-next-($id):main-next-($id)" -f
  }
}

