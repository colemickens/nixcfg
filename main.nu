#!/usr/bin/env nu

source ./nixlib.nu

let cachixpkgs_branch = "nixpkgs-stable"
let cpm = (open ./flake.lock | from json | get nodes | get $cachixpkgs_branch | get locked)

let options = {
  builders: {
    "x86_64-linux": "cole@147.28.150.135"
    # "x86_64-linux": ""
  },
  cachix: {
    pkgs: $"https://github.com/($cpm.owner)/($cpm.repo)/archive/($cpm.rev).tar.gz",
    cache: "colemickens",
    signkey: $"(open $"/run/secrets/cachix_signing_key_colemickens" | str trim)"
  },
  nixflags: [
    # "--accept-flake-config",
    "--builders-use-substitutes"
    "--option" "narinfo-cache-negative-ttl" "0"
    "--option" "extra-trusted-substituters" "https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
    "--option" "extra-substituters" "https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
    "--option" "extra-trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ],
}

check

# TODO: how to merge from another file
# if ("./overrides.nu" | path exists) {
#   (nu ./overrides.nu)
# }

############### Intenral lib #################
def downPaths [ target:string, ...buildPaths ] {
  let buildPaths = ($buildPaths | flatten)
  header "light_gray_reverse" $"download: ($target)"
  # let cmd = (^printf "'%s' " ([$"nix" "build" "--no-link" "-j0" $options.nixflags $buildPaths ] | flatten))
  # ^ssh $"cole@($target)" $cmd
  print -e $buildPaths
  (^nix build -j0 --no-link --eval-store auto
    --store $"ssh-ng://cole@($target)" $options.nixflags $buildPaths)
}

def deployHost [ arch: string, host: string ] {
  let target = (tailscale ip --4 $host | str trim)
  header "light_purple_reverse" $"deploy: ($host): START"

  let buildPaths = (autoCacheDrvs $options $arch [$".#toplevels.($host)"])
  let topout = ($buildPaths | first)

  downPaths $target $topout

  header "light_blue_reverse" $"deploy: ($host): switch: ($target)"
  let cmd1 = (^printf "'%s' " ([$"sudo" "nix" "build" "--no-link" "-j0" $options.nixflags $"--profile" "/nix/var/nix/profiles/system" $topout ] | flatten))
  let cmd2 =  $"sudo ($topout)/bin/switch-to-configuration switch"
  let script = $"($cmd1) && echo 'setup profile' && ($cmd2)"
  ^ssh $"cole@($target)" $script
  header "light_green_reverse" $"deploy: ($host): DONE"
  print -e $"(char nl)"
}

############### Intenral lib #################

def check [] {
  let len = (^git status --porcelain | complete | get stdout | str trim | str length)
  if ($len) != 0 {
    git status
    error make { msg: $"!! ERR: git has untracked or uncommitted changes!!" }
  }
}

def "main build" [ arch: string, ...flakeRefs ] {
  autoBuildDrvs $options $arch $flakeRefs
}

def "main cache" [ arch: string, ...flakeRefs ] {
  autoCacheDrvs $options $arch $flakeRefs
}

def "main dl" [ arch: string, ...flakeRefs ] {
  let buildPaths = (autoCacheDrvs $options $arch $flakeRefs)
  ^nix build -j0 --no-link $options.nixflags $buildPaths
  $buildPaths
}

def "main nix" [...args] {
  ^nix $options.nixflags $args
}

def "main deploy" [ arch: string, ...hosts] {
  let hosts = ($hosts | flatten)
  let hosts = (if ($hosts | length) != 0 { $hosts } else {
    let ref = $".#deployConfigs.($arch)"
    do -c { ^nix eval --json --apply "x: builtins.attrNames x" $ref }
      | complete | get stdout | from json
  })
  header "light_yellow_reverse" $"DEPLOY"
  print -e $hosts
  for h in $hosts {
    deployHost $arch $h
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
  header "light_yellow_reverse" "pkgup"

  let pkglist = if ($pkglist | length) == 0 {
    (^nix eval
      --json $".#packages.x86_64-linux"
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
      let c = (nix build -j0 --no-link $options.nixflags $pf | complete)
      if $c.exit_code != 0 {
        main dl "x86_64-linux" $pf # this shouldn't be necessary...
        # main cache "x86_64-linux" $pf
      }
      git commit -F $t $"./pkgs/($pkgname)"
    } else {
      print -e $"pkgup: ($pkgname): skip commit + build"
    }
  }
}

def "main lockup" [] {
  header "light_yellow_reverse" "lockup"
  ^nix flake lock --recreate-lock-file --commit-lock-file
}
def "main up" [...hosts] {
  header "light_red_reverse" "up" "▒"

  let hosts = [ "xeep" "raisin" "zeph" ]
  main inputup
  main pkgup
  main lockup
  main deploy x86_64-linux $hosts
}

def main [] { main up }

############

# not used in nixpkgs-wayland:

############

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
