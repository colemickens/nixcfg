#!/usr/bin/env nu

$env.NIXCFG_CI_BRANCH = (if "NIXCFG_CI_BRANCH" in $env { $env.NIXCFG_CI_BRANCH } else { (date now | format date '%s') })
$env.NIXCFG_CODE = (if "NIXCFG_CODE" in $env { $env.NIXCFG_CODE } else { "/home/cole/code" })
$env.LOGDIR = ([ ".outputs" $env.NIXCFG_CI_BRANCH ] | path join)

let c1 = "http://192.168.70.20.nip.io:9999/colemickens-cachix-org"
let c2 = "http://192.168.70.20.nip.io:9999/cache-nixos-org"

let nixflags = [
  # "--accept-flake-config",
  "--builders-use-substitutes"
  "--keep-going"
  "--option" "narinfo-cache-negative-ttl" "0"
  # "--option" "extra-trusted-substituters" $"($c1) ($c2) https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
  # "--option" "extra-substituters" $"($c1) ($c2) https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
  "--option" "extra-trusted-substituters" $"https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
  "--option" "extra-substituters" $"https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
  "--option" "extra-trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
]

let cachixpkgs_branch = "nixpkgs-stable"
let cpm = (open ./flake.lock | from json | get nodes | get $cachixpkgs_branch | get locked)
let cachixpkgs_url = $"https://github.com/($cpm.owner)/($cpm.repo)/archive/($cpm.rev).tar.gz"
let cachix_cache = "colemickens"
let cachix_signing_key = (open $"($env.HOME)/.cachix_signing_key" | str trim)

source ./nixlib.nu
source ./ci.nu

check

############### Intenral lib #################
def downPaths [ target:string, ...buildPaths ] {
  let buildPaths = ($buildPaths | flatten)
  header "light_gray_reverse" $"deploy: download: ($target)"
  let cmd = (^printf '%q ' ([$"nix" "build" "--no-link" "-j0" $nixflags $buildPaths ] | flatten))
  ^ssh $"cole@($target)" $cmd
}

def deployHost [ activate: bool, host: string, topout: string = "" ] {
  let target = (tailscale ip --4 $host | str trim)
  header "light_purple_reverse" $"deploy: start: ($host)"

  let topout = (if $topout != "" { $topout} else {
    let ref = $".#toplevels.($host)"
    let drvs = (evalFlakeRef $ref)
    let drvs = ($drvs | where { true })
    buildDrvs $drvs true
    ($drvs | get outputs | get out | first)
  })

  downPaths $target $topout

  header "light_blue_reverse" $"deploy: switch: ($host): ($target)"
  let cmd = (^printf "'%s' " ([$"sudo" "nix" "build" "--no-link" "-j0" $nixflags $"--profile" "/nix/var/nix/profiles/system" $topout ] | flatten))
  let cmd = if (not $activate) { $cmd } else {
    $"echo 'profile link...' && ($cmd) && echo 'switching...' && sudo ($topout)/bin/switch-to-configuration switch"
  }
  ^ssh $"cole@($target)" $cmd
  header "light_green_reverse" $"deploy: ($host): DONE"
  print -e $"(char nl)"
}

############### Intenral lib #################

def check [] {
  if ("SKIP_GIT_CHECK" in $env) {
    return
  }
  let len = (^git status --porcelain | complete | get stdout | str trim | str length)
  if ($len) != 0 {
    git status
    error make { msg: $"!! ERR: git has untracked or uncommitted changes!!" }
  }
}

def "main nix" [...args] {
  ^nix $nixflags $args
}

def "main build" [ flakeRef: string ] {
  let drvs = (evalFlakeRef $flakeRef)
  let drvs = ($drvs | where { true })
  print -e "****"
  print -e $drvs
  print -e "****"
  buildDrvs $drvs false
}

def "main cache" [ flakeRef: string ] {
  let drvs = (evalFlakeRef $flakeRef)
  # let drvs = ($drvs | where { true })
  buildDrvs $drvs true
}

def "main selfup" [] {
  nix build $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

def "main dl" [ flakeRef: string ] {
  let drvs = (evalFlakeRef $flakeRef)
  let drvs = ($drvs | where { true })
  buildDrvs $drvs true

  let outs = ($drvs | get outputs | get out)

  header "light_yellow_reverse" $"downloads from cache..."
  ^nix build -j0 --no-link $nixflags $outs
  $outs
}

def "main deploy" [...hosts] {
  header "light_yellow_reverse" $"DEPLOY"
  $hosts | par-each { |h|
    let drvs = (evalFlakeRef $".#toplevels.($h)")
    let drvs = ($drvs | where { true })
    buildDrvs $drvs true
    let out = ($drvs | get outputs | get out | first)
    deployHost true $h $out
  }
}

def "main inputup" [] {
  header "light_yellow_reverse" "inputup"
  let srcdirs = ([
    # nixpkgs and related branches
    "nixpkgs/master" "nixpkgs/cmpkgs"
    "nixpkgs/cmpkgs-cross" "nixpkgs/cmpkgs-cross-riscv64"
    
    # home-manager + my fork
    "home-manager/master" "home-manager/cmhm"

    # tow-boot and friends
    "tow-boot/development" "tow-boot/development-flakes"
    "tow-boot/radxa-rock5b" 
    "tow-boot/visionfive"
    # "tow-boot/rpi" "tow-boot/radxa-zero"

    # mobile-nixos and friends
    "mobile-nixos/master"
    "mobile-nixos/master-flakes"
    "mobile-nixos/openstick"
    # "mobile-nixos/pinephone-emmc" "mobile-nixos/reset-scripts" "mobile-nixos/sdm845-blue"
    
    # BUG: nixos-riscv64 - temporarily disabled
    "nixos-riscv64"

    # flake-firefox-nightly (not checked out anymore unless troubleshooting)
    # "flake-firefox-nightly"
    
    # nixpkgs-wayland
    "nixpkgs-wayland/master"

    # others, that I might (have) fork(ed)
    "nixos-hardware"
  ] | each { |it1| $it1 | each {|it| $"($env.NIXCFG_CODE)/($it)" } })

  let extsrcdirs = ([
    "linux/master"
  ] | each {|it| $"($env.HOME)/code-ext/($it)" })

  let srcdirs = ($srcdirs | append $extsrcdirs)

  for dir in $srcdirs {
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

def "main pkgup" [...pkglist] {
  header "light_yellow_reverse" "pkgup"

  let pkgref = $"($env.PWD)#packages.x86_64-linux"
  let pkglist = if ($pkglist | length) == 0 {
    (^nix eval
      --json $pkgref
      --apply 'x: builtins.attrNames x'
        | str trim
        | from json)
  }

  print -e $pkglist

  for pkgname in $pkglist {
    header "light_yellow_reverse" $"pkgup: ($pkgname)"

    let maybefork = $"/home/cole/code/($pkgname)"
    if ($maybefork | path exists) {
      do -i { ^git -C $maybefork rebase --abort }
      ^git -C $maybefork pull --rebase --no-gpg-sign
      ^git -C $maybefork push origin HEAD -f
    }

    let t = $"/tmp/commit-msg-($pkgname)"
    # TODO: see if this can be host agnostic, nix-update and main build should just work
    let pf = $"($pkgref).($pkgname)"
    rm -f $t
    (nix-update
      --flake
      --format
      --version branch
      --write-commit-message $t
      $pkgname)
      
    main dl $pf
    
    if ($t | path exists) and (open $t | str trim | str length) != 0) {
      print -e $"pkgup: ($pkgname): commiting..."
      git commit -F $t $"./pkgs/($pkgname)"
    }
  }
}

def "main lockup" [] {
  header "light_yellow_reverse" "lockup"
  ^nix flake lock --recreate-lock-file --commit-lock-file
}

def "main ciattrs" [] {
  let drvs = (evalFlakeRef '.#ciAttrs')
  buildDrvs $drvs true
  $drvs
}

def "main upx" [ ...hosts ] {
  loop {
    do -i {
      main up
    }
    sleep 120sec
  }
}

def "main up" [...hosts] {
  header "light_red_reverse" "up" "▒"

  main inputup
  main lockup
  # main pkgup
  main dl '.#devShells.x86_64-linux.ci'

  main ciattrs

  main deploy raisin xeep zeph
  main deploy vf2 rocky
  main deploy openstick
}

def main [] { main up }

## CI #########################################################################
# TODO: split to `ci.nu`?

let branch = 'ci-auto-update'

def action-post [] {
  git push -f origin $branch
}

def "main action-ci" [] {
  # TODO: git-repo-manager?
  git switch -c $branch
  # TODO: eval each attr individually into a 'gcroots' dir...
  # TODO: evaluate fanning out to multiple eval machines, then building?
  # ci-grm
  main inputup # should be a no-op even with nothing cloned
  main pkgup
  main lockup
  main ciattrs
  main dl '.#devShells.x86_64-linux.ci'
  # action-post
}

# ## action-nextci ###############################################################
# def updateInput [ name: string baseBr: string newBr: string upRemoteName: string upstreamUrl: string upstreamBr: string ] {
#   let originUrl = $"https://github.com/colemickens/($name)"
#   let baseDir = $"($env.PWD)/../($name)/($baseBr)"
#   let newDir = $"($env.PWD)/../($name)/($newBr)"
#   if (not ($baseDir | path exists)) {
#     do -c { mkdir $baseDir }
#     do -c { git clone $originUrl -b $baseBr $baseDir }
#   }
#   if (not ($newDir | path exists)) {
#     echo $"check ($newDir)"
#     (git -C $baseDir remote add "$upRemoteName" $upstreamUrl)
#     rm -rf $newDir
#     (git -C $baseDir worktree prune)
#     (git -C $baseDir branch -D $newBr)
#     do -c { git -C $baseDir worktree add $newDir }
#   }

#   do -c {
#     git -C $newDir reset --hard $baseBr
#     git -C $newDir rebase $"($upRemoteName)/($upstreamBr)"
#     git -C $newDir push origin HEAD
#   }
# }

# def "main action-nextci" [] {
#   let id = "xyz"
#   updateInput $"home-manager" "cmhm" $"cmhm-next-($id)" "nix-community" "https://github.com/nix-community/home-manager" "master"
#   updateInput $"nixpkgs" "cmpkgs" $"cmpkgs-next-($id)" "nixos" "https://github.com/nixos/nixpkgs" "nixos-unstable"
  
#   let p = $"($env.PWD)/../nixcfg_main-next-($id)"
#   if (not ($p | path exists)) {
#     rm -rf $p
#     git worktree prune
#     git worktree add $p
#   }
  
#   do {
#     git -C $p rebase main

#     do {
#       cd $p
#       let args = [
#         --recreate-lock-file
#         --override-input 'nixpkgs' $"github:colemickens/nixpkgs/cmpkgs-next-($id)"
#         --override-input 'home-manager' $"github:colemickens/home-manager/cmhm-next-($id)"
#         --commit-lock-file
#       ]
#       nix flake lock $args
  
#       ./main.nu ci eval
#       ./main.nu ci build
#       ./main.nu ci push
#     }
    
#     git push origin $"nixcfg_main-next-($id):main-next-($id)" -f
#   }
# }
