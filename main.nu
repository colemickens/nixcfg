#!/usr/bin/env nu

let cachixpkgs = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz" # used by nix-shell cachix
# TODO: I think this bug got fixed???
# let nix = "./misc/nix.sh"
let nix = "nix"
let nixopts = [
  "--builders-use-substitutes" "--option" "narinfo-cache-negative-ttl" "0"
  # TODO: files bugs such that we can exclusively use the flake's values??
  "--option" "extra-trusted-substituters" "'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org https://nix-community.cachix.org'"
  "--option" "extra-trusted-public-keys" "'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs='"
];

def getpref [ b: string ] {
  let pp = $".pref.($b)"
  if $b in $env {
    return ($env | get $b)
  } else if ($pp | path exists) {
    print -e $"getpref: ($b): check ($pp)"
    let builder = (open $".pref.($b)" | str trim)
    return $builder
  } else {
    return "cole@localhost" # TODO this isn't finished for aarch64
  }
}
let-env BUILDER_X86 = (getpref "BUILDER_X86")
let-env BUILDER_A64 = (getpref "BUILDER_A64")

print -e $"BUILDER_X86 = ($env.BUILDER_X86)"
print -e $"BUILDER_A64 = ($env.BUILDER_A64)"

check

let cachix_cache = "colemickens"
let-env CACHIX_SIGNING_KEY = (open $"/run/secrets/cachix_signing_key_colemickens" | str trim)

def check [] {
  let res = (^git status --porcelain | complete)
  let len = ($res.stdout | str trim | str length)
  if ($len) != 0 {
    git status
    error make { msg: $"!! ERR: git has untracked or uncommitted changes!!" }
  }
}

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text) "
  let text = $"($text | fill -a l -c $spacer -w 50)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def evalDrv [ ref: string ] {
  header "light_cyan_reverse" $"eval: ($ref)"
  let eval = (^nix-eval-jobs
    --flake $ref
    --check-cache-status)
  $eval
    | from ssv --noheaders
    | get column1
    | each { |it| ($it | from json ) }
}

def buildDrvs [ doCache: bool drvs: table ] {
  let builds = [
    {builder: $env.BUILDER_A64, drvs: ($drvs | where system == "aarch64-linux")}
    {builder: $env.BUILDER_X86, drvs: ($drvs | where system == "x86_64-linux")}
  ]
  for build in $builds {
    buildDrvs__ $doCache $build.builder $build.drvs
  }
}

def buildDrvs__ [ doCache: bool buildHost: string drvs: list ] {
  header "light_blue_reverse" $"build: ($drvs | length) drvs on ($buildHost)]"
  print -e $drvs
  if ($drvs | length) == 0 { return; } # TODO_NUSHELL: xxx
  let drvPaths = ($drvs | get "drvPath")
  let drvBuilds = ($drvPaths | each {|i| $"($i)^*"})

  # TODO: try this in a loop a few times, sometimes it fails "too many root paths" <- TODO: File a bug for this
  ^$nix copy $nixopts --no-check-sigs --to $"ssh-ng://($buildHost)" --derivation $drvBuilds

  ^echo $nix build $nixopts --store $"ssh-ng://($buildHost)" -L $drvBuilds
  ^$nix build $nixopts --store $"ssh-ng://($buildHost)" -L $drvBuilds

  if $doCache {
    # do caching here...
    let outs = ($drvs | get outputs | flatten | get out | flatten)
    let outsStr = ($outs | each {|it| $"($it)(char nl)"} | str join)
    header "purple_reverse" $"cache: remote: ($outs | length) paths"
    print -e $outs
    (^ssh $buildHost
      ([
        $"printf '%s' '($outsStr)' | env CACHIX_SIGNING_KEY='($env.CACHIX_SIGNING_KEY)' "
        $"nix-shell -I nixpkgs=($cachixpkgs) -p cachix --command 'cachix push ($cachix_cache)'"
      ] | str join ' ')
    )
  }
}

# TODO: we shouldn't need this mostly...
# def "main nixbuild" [ a: string ] {
#   ^nix build $nixopts $a
# }

def downDrvs [ drvs: table target: string ] {
  header "purple_reverse" $"download: ($target): $drvs"
  let builds = ($drvs | get outputs | get out)
  print -e $builds
  ^echo ^ssh $"cole@($target)" (([ "nix" "build" "--no-link" "-j0" $nixopts $builds ] | flatten) | str join ' ')
  ^ssh $"cole@($target)" (([ "nix" "build" "--no-link" "-j0" $nixopts $builds ] | flatten) | str join ' ')
  # if ($env.LAST_EXIT_CODE != 0) {
  #   error make { msg: $"failed to down to ($target)"}
  # }
}

def deployHost [ host: string ] {
  let target = (tailscale ip --4 $host | str trim)
  header light_gray_reverse $"deploy: ($host) -> ($target)"
  let drvs = (evalDrv $"/home/cole/code/nixcfg#toplevels.($host)")
  # NUSHELL BUG:
  let drvs = ($drvs | where { |it| $it.isCached == false or $it.isCached == true})
  buildDrvs true $drvs
  downDrvs $drvs $target
  let topout = ($drvs | get "outputs" | flatten | get "out" | flatten | first)
  let cs = (do -c { ^ssh $"cole@($target)" $"readlink -f /run/current-system" } | str trim)
  if ($cs == $topout) { header light_purple_reverse $"deploy: ($host): already up-to-date"; return }

  header light_purple_reverse $"deploy: ($host): apply and switch"
  ^ssh $"cole@($target)" (([ "sudo" "nix" "build" "--no-link" "-j0" $nixopts "--profile" "/nix/var/nix/profiles/system" $topout ] | flatten) | str join ' ')
  ^ssh $"cole@($target)" $"sudo '($topout)/bin/switch-to-configuration' switch"
}

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

def "main deploy" [...h] {
  let h = ($h | flatten)
  let h = (if ($h | length) != 0 { $h } else {
    let ref = $".#deployConfigs"
    do -c { ^nix eval --json --apply "x: builtins.attrNames x" $ref }
      | complete | get stdout | from json
  })
  let h = ($h | flatten)
  header light_gray_reverse $"DEPLOY"
  print -e $h
  $h | flatten | each { |h| deployHost $h }
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
  # main pkgup
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
