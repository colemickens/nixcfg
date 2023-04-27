#!/usr/bin/env nu

# TODO: use a flake input for cachixpkgs and re-use?? except that we use this with NIX_PATH
let cachixpkgs = "https://github.com/nixos/nixpkgs/archive/nixos-22.11.tar.gz" # used by nix-shell cachix
# TODO: I think this bug got fixed???
# let nix = "./misc/nix.sh"
let nix = "nix"
let nixopts = [
  "--builders-use-substitutes" "--option" "narinfo-cache-negative-ttl" "0"
  # TODO: files bugs such that we can exclusively use the flake's values??
  "--option" "extra-substituters" "'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org https://nix-community.cachix.org'"
  "--option" "extra-trusted-public-keys" "'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs='"
];

source ./nixlib.nu

check

let-env CACHIX_CACHE = "colemickens"
let-env CACHIX_SIGNING_KEY = (open $"/run/secrets/cachix_signing_key_colemickens" | str trim)

def check [] {
  let res = (^git status --porcelain | complete)
  let len = ($res.stdout | str trim | str length)
  if ($len) != 0 {
    git status
    error make { msg: $"!! ERR: git has untracked or uncommitted changes!!" }
  }
}

# def "main eval" [ drv: string ] {
#   let res = (evalDrv $drv)
#   $res | flatten outputs
# }

def "main build" [ drv: string ] {
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs false $drvs
}

def "main cache" [ drv: string ] {
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs true $drvs
}

def "main dl" [ drv: string ] {
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs true $drvs
  nix build -j0 $nixopts ($drvs | flatten outputs | get out)
}

def "main nix" [...args] {
  ^nix $nixopts $args
}

def "main rbuild" [ drv: string ] {
  let drvs = (evalDrv $drv)
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs true $drvs
  let out = ($drvs | get "outputs" | flatten | get "out" | flatten | first)
  ^nix build $nixopts -j0 $out
}

def "main deploy" [...hosts] {
  let hosts = ($hosts | flatten)
  let hosts = (if ($hosts | length) != 0 { $hosts } else {
    let ref = $".#deployConfigs"
    do -c { ^nix eval --json --apply "x: builtins.attrNames x" $ref }
      | complete | get stdout | from json
  })
  header light_gray_reverse $"DEPLOY"
  for h in $hosts {
    deployHost $h
  }
}

def "main inputup" [] {
  header yellow_reverse "inputup"
  let srcdirs = ([
    # nixpkgs and related branches
    "nixpkgs/master" "nixpkgs/cmpkgs"
    "nixpkgs/cmpkgs-cross" "nixpkgs/cmpkgs-cross-riscv64"
    
    # home-manager + my fork
    "home-manager/master" "home-manager/cmhm"

    # tow-boot and friends
    "tow-boot/development" "tow-boot/development-flakes"
    # "tow-boot/rpi" "tow-boot/radxa-zero" "tow-boot/radxa-rock5b" "tow-boot/visionfive"

    # mobile-nixos and friends
    "mobile-nixos/master"
    "mobile-nixos/master-flakes"
    # "mobile-nixos/openstick" "mobile-nixos/pinephone-emmc" "mobile-nixos/reset-scripts" "mobile-nixos/sdm845-blue"
    
    # BUG: nixos-riscv64 - temporarily disabled
    # "nixos-riscv64"

    # flake-firefox-nightly (not checked out anymore unless troubleshooting)
    # "flake-firefox-nightly"
    
    # nixpkgs-wayland
    "nixpkgs-wayland/master"
  ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

  let extsrcdirs = ([
    "linux/master"
  ] | each {|it| $"($env.HOME)/code-ext/($it)" })

  let srcdirs = ($srcdirs | append $extsrcdirs)

  for dir in $srcdirs {
    if (not ($dir | path exists)) {
      print -e $"(ansi yellow_dimmed)inputup: warn: skipping non-existent $dir(ansi reset)"
    }
    print -e $"(ansi yellow_dimmed)inputup: check:(ansi reset) ($dir)"
    do -i { ^git -C $dir rebase --abort }
    ^git -C $dir pull --rebase --no-gpg-sign
    ^git -C $dir push origin HEAD -f
  }
}

def "main pkgup" [...pkglist] {
  header yellow_reverse "pkgup"

  let pkglist = if ($pkglist | length) == 0 {
    (^nix eval
      --json $".#packages.x86_64-linux"
      --apply 'x: builtins.attrNames x'
        | str trim
        | from json)
  }

  print -e $pkglist

  for pkgname in $pkglist {
    header yellow_reverse $"pkgup: ($pkgname)"

    let maybefork = $"/home/cole/code/($pkgname)"
    if ($maybefork | path exists) {
      do -i { ^git -C $maybefork rebase --abort }
      ^git -C $maybefork pull --rebase --no-gpg-sign
      ^git -C $maybefork push origin HEAD -f
    }

    let t = $"/tmp/commit-msg-($pkgname)"
    # TODO: see if this can be host agnostic, nix-update and main build should just work
    let p = $"pkgs.x86_64-linux.($pkgname)"
    let pf = $"/home/cole/code/nixcfg#($p)"
    rm -f $t
    (nix-update
      --flake
      --format
      --version branch
      --write-commit-message $t
      $p)

    if ($t | path exists) and (open $t | str trim | str length) != 0 {
      print -e "pkgup> test if exists"
      let c = (nix build -j0 $nixopts $pf | complete)
      if $c.exit_code != 0 {
        main cache $pf
      }
      git commit -F $t $"./pkgs/($pkgname)"
    } else {
      print -e $"pkgup: ($pkgname): skip commit + build"
    }
  }

  let pkgs_ = ($pkglist | each {|p| $".#packages.x86_64-linux.($p)" })
  nix build $nixopts $pkgs_
}

# TODO: rpi likely given up on, remove?
# def "main rpiup" [] {
#   header yellow_reverse "rpiup"
#   # ^./misc/rpi/rpi-update.nu
# }

def "main lockup" [] {
  header yellow_reverse "lockup"
  ^$nix flake lock --recreate-lock-file --commit-lock-file
}
def "main cache_x86" [] {
  header yellow_reverse "cache_x86"
  main cache "'/home/cole/code/nixcfg#ciJobs.x86_64-linux.default'"
}
def "main cache_a64" [] {
  header yellow_reverse "cache_a64"
  main cache "'/home/cole/code/nixcfg#ciJobs.aarch64-linux.default'"
}
def "main up" [...hosts] {
  header red_reverse "up" "▒"

  main inputup
  main pkgup
  main lockup
  main cache_x86
  main deploy $hosts
  # main cache_a64 #TODO: what do?
}

def main [] { main up }

# TODO: revisit actions
# ## action-rpiup ###############################################################
# def "main action-rpiup" [] {
#   # TODO: we gotta clone repos and stuff, right?
#   main rpiup
# }

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
