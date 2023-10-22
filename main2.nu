#!/usr/bin/env nu

# let nixflags = [
#   # "--accept-flake-config",
#   "--builders-use-substitutes"
#   "--keep-going"
#   "--option" "narinfo-cache-negative-ttl" "0"
#   # "--option" "extra-trusted-substituters" $"($c1) ($c2) https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
#   # "--option" "extra-substituters" $"($c1) ($c2) https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
#   "--option" "extra-trusted-substituters" $"https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
#   "--option" "extra-substituters" $"https://cache.nixos.org https://colemickens.cachix.org https://nix-community.cachix.org https://nixpkgs-wayland.cachix.org https://unmatched.cachix.org"
#   "--option" "extra-trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
# ]

let buildhost = (tailscale ip --4 slynux)

let cachixpkgs_branch = "nixpkgs-stable"
let cpm = (open ./flake.lock | from json | get nodes | get $cachixpkgs_branch | get locked)
let cachixpkgs_url = $"https://github.com/($cpm.owner)/($cpm.repo)/archive/($cpm.rev).tar.gz"
let cachix_cache = "colemickens"
let cachix_signing_key = (open $"($env.HOME)/.cachix_signing_key" | str trim)

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}
# source ./nixlib.nu

check

############### Intenral lib #################
# def downPaths [ target:string, ...buildPaths ] {
#   let buildPaths = ($buildPaths | flatten)
#   header "light_gray_reverse" $"deploy: download: ($target)"
#   let cmd = (^printf '%q ' ([$"nix" "build" "--no-link" "-j0" $nixflags $buildPaths ] | flatten))
#   ^ssh $"cole@($target)" $cmd
# }

# def deployHost [ activate: bool, host: string, topout: string = "" ] {
#   let target = (tailscale ip --4 $host | str trim)
#   header "light_purple_reverse" $"deploy: start: ($host)"

#   let topout = (if $topout != "" { $topout} else {
#     let ref = $".#toplevels.($host)"
#     let drvs = (evalFlakeRef $ref)
#     let drvs = ($drvs | where { true })
#     buildDrvs $drvs true
#     ($drvs | get outputs | get out | first)
#   })

#   downPaths $target $topout

#   header "light_blue_reverse" $"deploy: switch: ($host): ($target)"
#   let cmd = (^printf "'%s' " ([$"sudo" "nix" "build" "--no-link" "-j0" $nixflags $"--profile" "/nix/var/nix/profiles/system" $topout ] | flatten))
#   let cmd = if (not $activate) { $cmd } else {
#     $"echo 'profile link...' && ($cmd) && echo 'switching...' && sudo ($topout)/bin/switch-to-configuration switch"
#   }
#   ^ssh $"cole@($target)" $cmd
#   header "light_green_reverse" $"deploy: ($host): DONE"
#   print -e $"(char nl)"
# }

############### Intenral lib #################

def check [] {
  if ((0 != (^git status --porcelain | complete | get stdout | str trim | str length)) and (not ("SKIP_GIT_CHECK" in $env)) {
    git status
    error make { msg: $"!! ERR: git has untracked or uncommitted changes!!" }
  }
}

# main build "" --cache
# main build "" --download
# main nix ... # passthrough to nix

def "main selfup" [] {
  sudo nix build --profile "/nix/var/nix/profiles/system" $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

# def "main deploy" [...hosts] {
#   header "light_yellow_reverse" $"DEPLOY"
#   $hosts | par-each { |h|
#     let drvs = (evalFlakeRef $".#toplevels.($h)")
#     let drvs = ($drvs | where { true })
#     buildDrvs $drvs true
#     let out = ($drvs | get outputs | get out | first)
#     deployHost true $h $out
#   }
# }

def "main inputup" [] {
  header "light_yellow_reverse" "inputup"
  let srcdirs = ([
    [ "nixpkgs/master" "nixpkgs/nixos-unstable" "nixpkgs/cmpkgs" ]
    [ "home-manager/master" "home-manager/cmhm" ]
    #[ "mobile-nixos/development" "mobile-nixos/development-flakes" "mobile-nixos/openstick" ]
  ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

  let extsrcdirs = ([
    [
      "linux/master"
      # "linux/openstick"
    ]
  ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code-ext/($it)" } })

  let srcdirs = ($srcdirs | append $extsrcdirs)

  $srcdirs | par-each { |dirGroup|
    for dir in $dirGroup {
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
}

def "main pkgup" [...pkglist] {
  header "light_yellow_reverse" "pkgup"

  if ("SKIP_PKGUP" in $env) {
    header "light_yellow_reverse" "pkgup SKIP SKIP SKIP"
    return
  }

  let pkgref = $"($env.PWD)#packages.x86_64-linux"
  let pkglist = if ($pkglist | length) == 0 {
    (^nix eval
      --json $pkgref
      --apply 'x: builtins.attrNames x'
        | str trim
        | from json)
  } else { $pkglist }

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
      
    # try {
    #   main dl $pf
    
    #   if ($t | path exists) and (open $t | str trim | str length) != 0) {
    #     print -e $"pkgup: ($pkgname): commiting..."
    #     git commit -F $t $"./pkgs/($pkgname)"
    #   }
    # } catch {
    #   git restore $"./pkgs/($pkgname)"
    #   print -e $"pkgup: ($pkgname): restoring/undoing"
    # }
  }
}

def "main lockup" [] {
  header "light_yellow_reverse" "lockup"
  ^nix flake lock --recreate-lock-file --commit-lock-file
}

# def "main ciattrs" [] {
#   let drvs = (evalFlakeRef '.#ciAttrs')
#   buildDrvs $drvs true
#   $drvs
# }

def "main up" [...hosts] {
  # header "light_red_reverse" "up" "▒"

  main inputup
  main lockup

  nix-fast-build --remote $"ssh-ng://($buildhost)" ".#devShells.x86_64-linux"
  # nix-fast-build here again
  # main dl ".#devShells.x86_64-linux.ci"
  # main dl '.#devShells.x86_64-linux.dev'

  main pkgup

  # nix-fast-build
  #   --remote
  #   --no-download

  # then manually cachix it up

  # see if we get result/ links without `download`
  # if so, use those to direct deploy without re-evaluating
  # main ciattrs

  # main deploy raisin
  # main deploy slynux
  # main deploy zeph
}

def main [] {
  print -e "use a subcommand"
  exit 1
}
