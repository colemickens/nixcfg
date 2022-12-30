#!/usr/bin/env nu

let cidir = "/tmp/nixci"; mkdir $cidir
let nixpkgs = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz" # used by nix-shell cachix
let nix = "./misc/nix.sh"
let nixopts = [ "--no-link" "--builders-use-substitutes" "--option" "narinfo-cache-negative-ttl" "0" ]
# let builder = if (not ("NIX_BUILDER" in $env)) { "nix" } else { $env | get NIX_BUILDER | str trim }
let builder_x86 = (if ("BUILDER_X86" in $env) { $env | get "BUILDER_X86" | str trim } else { ^tailscale ip --4 "slynux" | str trim })
let builder_a64 = (if ("BUILDER_A64" in $env) { $env | get "BUILDER_A64" | str trim } else { "colemickens@aarch64.nixos.community" })

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
    --flake $ref
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
  let drvs_ = ($drvs_ | where system == $arch)
  let drvs = $drvs_
  # let drvs = ($drvs_ | where isCached == false)
  header "light_blue_reverse" $"build: ($arch) ($drvs | length) drvs on ($buildHost) [cache=($cache)]"
  if (($drvs | length) > 0) {
    print -e ($drvs | select drvPath outputs | flatten)
    let drvPaths = ($drvs | get "drvPath")
    let nixopts = (if ($buildHost == "localhost") { $nixopts } else {
      $nixopts | append [ "--store" $"ssh-ng://($buildHost)" ]
    })
    if ($buildHost == "localhost") {
      ^$nix build --keep-going $nixopts $drvPaths
      if ($env.LAST_EXIT_CODE != 0) { error make { msg: $"failed to build..."} }
    } else {
      ^$nix copy --no-check-sigs --to $"ssh-ng://($buildHost)" --derivation $drvPaths
      ^$nix build $nixopts -L $drvPaths
      if ($env.LAST_EXIT_CODE != 0) { error make { msg: $"failed to build..."} }
    }
  }

  if ($cache and ($drvs | length) > 0) {
    let outs = ($drvs | get "outputs" | flatten | get "out" | flatten)
    let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str collect)
    if $buildHost == "localhost" {
      header "purple_reverse" $"cache: ($outs | length) paths"
      echo $outsStr | ^cachix push $cachix_cache
    } else {
      header "purple_reverse" $"cache: remote: ($outs | length) paths"
      let sshExe = ([
        $"printf '%s' '($outsStr)' | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' "
        $"nix-shell -I nixpkgs=($nixpkgs) -p cachix --command 'cachix push ($cachix_cache)'"
    ] | str join ' ')
      ^ssh $buildHost $sshExe
    }
  }
}

def deployHost [ host: string ] {
  header light_gray_reverse $"deploy: ($host)"
  let jobs = evalDrv $"/home/cole/code/nixcfg#toplevels.($host)"
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
    let pullargs = (([ "sudo" "nix" "build" "-j0" $nixopts "--profile" "/nix/var/nix/profiles/system" $topout ] | flatten) | str join ' ')
    ^ssh $"cole@($target)" $pullargs
    if ($env.LAST_EXIT_CODE != 0) {
      error make { msg: $"failed to pull for ($host)"}
    }
    header light_purple_reverse $"deploy: ($host): switch"
    ^ssh $"cole@($target)" $"sudo '($topout)/bin/switch-to-configuration' switch"
    if ($env.LAST_EXIT_CODE != 0) {
      error make { msg: $"failed to switch for ($host)"}
    }
    
    null
  }
}

# def "main deploy" [ h: list ] {
def "main deploy" [...h] {
  let h = ($h | flatten)
  header light_gray_reverse $"DEPLOY"
  let h = (if ($h | length) != 0 { $h } else {
    let ref = $".#deployConfigs"
    do -c { ^nix eval --json --apply "x: builtins.attrNames x" $ref }
      | complete | get stdout | from json
  })
  let h = ($h | flatten)
  $h | flatten | each { |h| deployHost $h }
}

def "main inputup" [] {
  header yellow_reverse "inputup"
  let srcdirs = ([
    [ "nixpkgs/master" "nixpkgs/cmpkgs" "nixpkgs/cmpkgs-cross" "nixpkgs/cmpkgs-cross-riscv64" ]
    [ "home-manager/master" "home-manager/cmhm" ]
    [ "tow-boot/development" "tow-boot/development-flakes"
      "tow-boot/rpi" "tow-boot/radxa-zero" "tow-boot/radxa-rock5b" "tow-boot/visionfive" ]
    [ "mobile-nixos/master"
      "mobile-nixos/master-flakes"
      "mobile-nixos/openstick" "mobile-nixos/pinephone-emmc" "mobile-nixos/reset-scripts" "mobile-nixos/sdm845-blue" ]
    [ "nixos-riscv64" ]
    [ "flake-firefox-nightly" ]
    [ "nixpkgs-wayland/master" ]
  ] | flatten | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

  let srcdirs = ($srcdirs | append (["linux/master"] | each {|it| $"($env.HOME)/code-ext/($it)"}))

  $srcdirs | each { |dir|
    print -e $"input: ($dir): (ansi yellow_dimmed)check(ansi reset)"

    # rebase, ignore if we're not rebasing
    ^git -C $dir rebase --abort
    # pull, rebase, errors here are fatal, we want things "clean/rebased/pushed"
    ^git -C $dir pull --rebase --no-gpg-sign
    if ($env.LAST_EXIT_CODE != 0) {
      print -e $"(ansi red) input: ($dir): failed rebase(ansi reset)"
      error make { msg: $"rebase failed for ($dir)"}
      break
    }
    # git push => also fatal if fails
    ^git -C $dir push origin HEAD -f
    if ($env.LAST_EXIT_CODE != 0) {
      print -e $"(ansi red) input: ($dir): failed push(ansi reset)"
      error make { msg: $"push failed for ($dir)"};
      break
    }

    print -e $"input: ($dir): (ansi green)ok(ansi reset)"
    []
  } | flatten
}

def "main pkgup" [] {
  header yellow_reverse "pkgup"
  do {
    cd pkgs
    ^./main.nu update

    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "failed to pkgs-update.nu" } }
  }
}

def "main rpiup" [] {
  header yellow_reverse "rpiup"
  ^./misc/rpi/rpi-update.nu
  git -C "~/code/nixpkgs/rpipkgs" push origin HEAD -f
  git -C "~/code/nixpkgs/rpipkgs-dev" push origin HEAD -f
  if ($env.LAST_EXIT_CODE != 0) { error make { msg: "failed to rpi-update" } }
}
def "main lockup" [] {
  header yellow_reverse "lockup"
  ^$nix flake lock --recreate-lock-file
  if ($env.LAST_EXIT_CODE != 0) { error make { msg: "failed to lockup" } }
}

def "main eval" [ drv: string ] { evalDrv $drv }
def "main build" [ drv: string ] {
  echo $">>>> ($drv)"
  let drvs = evalDrv $drv
  buildDrvs $drvs false
  print -e ($drvs | get outputs | flatten)
}
def "main cache" [ drv: string] {
  let drvs = evalDrv $drv
  buildDrvs $drvs true
  print -e ($drvs | get outputs | flatten)
}
def "main cachedl" [ drv: string] {
  let drvs = evalDrv $drv
  buildDrvs $drvs true
  let builds = ($drvs | get outputs | get out)
  header light_gray_reverse $"download"
  ^$nix build -j0 --option narinfo-cache-negative-ttl 0 $builds
  if ($env.LAST_EXIT_CODE != 0) { error make { msg: "failed to dl from cache" } }
  $builds
}

def "main loopup" [] {
  loop {
    main up
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: failed" } }
    print -e $"(ansi purple)waiting 60 seconds...(ansi reset)"
    sleep 60sec
  }
}

def "main up" [] {
  header red_reverse "loopup" "▒"

  main inputup
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: inputup failed" } }
  main pkgup
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: pkgup failed" } }
  main rpiup
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: rpiup failed" } }
  main lockup
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: lockup failed" } }
  
  main ci eval
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: ci eval failed" } }
  main ci build
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: ci build failed" } }
  main ci push
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: ci push failed" } }

  main build "'/home/cole/code/nixcfg#ciJobs.aarch64-linux.default'"
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: build ciJobs.aarch64-linux.default failed" } }

  main deploy
    if ($env.LAST_EXIT_CODE != 0) { error make { msg: "up: deploy failed" } }
}

def main [] {
  main up
}

###############################################################################
## CI
###############################################################################
def "main ci eval" [] {
  let r = (evalDrv "'~/code/nixcfg#ciJobs.x86_64-linux.default'")
  $r | to json | save -f --raw $"($cidir)/drvs.json"
}
def "main ci build" [] {
  let drvs = (open --raw $"($cidir)/drvs.json" | from json)
  buildDrvs $drvs false
  
  header light_blue_reverse $"ci build summary"
  $drvs
}
def "main ci push" [] {
  let drvs = (open --raw $"($cidir)/drvs.json" | from json)
  buildDrvs $drvs true
}
def "main ci" [] {
  main ci eval
  main ci build
  main ci push
}

def updateInput [ name: string baseBr: string newBr: string upRemoteName: string upstreamUrl: string upstreamBr: string ] {
  let originUrl = $"https://github.com/colemickens/($name)"
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

