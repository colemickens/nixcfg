#!/usr/bin/env nu

let nixcfg_root = $env.FILE_PWD

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

let builder_local = {
  host: "localhost",
  nfbargs: [ --no-nom ],
}
let builder_name = (if "NIXCFG_BUILDER" in $env { $env.NIXCFG_BUILDER } else { "raisin" })
let builder = if $builder_name == "local" { $builder_local } else {
  let host = ^tailscale ip --4 $builder_name
  {
    host: $host
    nfbargs: [ "--remote" $host --eval-max-memory-size 4096 --eval-workers 4 --no-nom --no-download ],
  }
}

let cachixpkgs_branch = "nixpkgs-stable"
let cpm = (open $"($nixcfg_root)/flake.lock" | from json | get nodes | get $cachixpkgs_branch | get locked)
let cachixpkgs_url = $"https://github.com/($cpm.owner)/($cpm.repo)/archive/($cpm.rev).tar.gz"
let cachix_cache = "colemickens"
let cachix_signing_key = (open $"($env.HOME)/.cachix_signing_key" | str trim)

############### Internal lib #################

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def "main deploy" [ host: string, --activate: bool = true, --toplevel: string = ""] {
  let target = (tailscale ip --4 $host | str trim)
  let toplevel = if $toplevel != "" { $toplevel } else {
    let res = main nfb --cache true $".#toplevels.($host)"
    $res | find $host | first
  }
  header "light_purple_reverse" $"deploy: start: ($host)"

  header "light_blue_reverse" $"deploy: profile dl: ($host): ($toplevel) ($activate)"
  # TODO: better way to interop into shellex?
  let cmd = (^printf "'%s' " ([
    $"sudo" "nix" "build" "--no-link" "-j0" $nixflags
    "--option" "narinfo-cache-negative-ttl" "0"
    $"--profile" "/nix/var/nix/profiles/system" $toplevel
  ] | flatten))
  let cmd = (if (not $activate) { $cmd } else {
    let $switch_cmd = (^printf "'%s' " ([
      "sudo" $"($toplevel)/bin/switch-to-configuration" "switch"
    ] | flatten))
    $"($cmd) && ($switch_cmd)"
  })
  print -e $"(ansi grey)running cmd: ($cmd)(ansi reset)"

  ^ssh $"cole@($target)" -- $cmd
  header "light_green_reverse" $"deploy: ($host): DONE"
  print -e $"(char nl)"
}

############### Intenral lib #################

def check [] {
  if ("SKIP_GIT_CHECK" in $env) {
    return
  }
  let len = ^git status --porcelain | complete | get stdout | str trim | str length
  if ($len) != 0 {
    git status
    error make { msg: $"!! ERR: git has untracked or uncommitted changes!!" }
  }
}

def "main nix" [...args] {
  ^nix $nixflags $args
}

def "main selfup" [] {
  sudo nix build --profile "/nix/var/nix/profiles/system" $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

def "main inputup" [] {
  header "light_yellow_reverse" "inputup"
  let srcdirs = ([
    "nixpkgs/master" "nixpkgs/nixos-unstable" "nixpkgs/cmpkgs"
    "home-manager/master" "home-manager/cmhm"
    "mobile-nixos/development" "mobile-nixos/development-flakes" "mobile-nixos/openstick"
  ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

  let extsrcdirs = ([
    "linux/master"
    # "linux/openstick"
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

# def "main inputup2" [] {
#   header "light_yellow_reverse" "inputup"
#   let srcdirs = ([
#     [ "nixpkgs/master" "nixpkgs/nixos-unstable" "nixpkgs/cmpkgs" ]
#     [ "home-manager/master" "home-manager/cmhm" ]
#     [ "mobile-nixos/development" "mobile-nixos/development-flakes" "mobile-nixos/openstick" ]
#   ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

#   let extsrcdirs = ([
#     [
#       "linux/master"
#       # "linux/openstick"
#     ]
#   ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code-ext/($it)" } })

#   let srcdirs = ($srcdirs | append $extsrcdirs)

#   $srcdirs | par-each { |dirGroup|
#     for dir in $dirGroup {
#       if (not ($dir | path exists)) {
#         print -e $"(ansi yellow_dimmed)inputup: skip:(ansi reset) ($dir)"
#         continue
#       }
#       print -e $"(ansi yellow_dimmed)inputup: check:(ansi reset) ($dir)"
#       do -i { ^git -C $dir rebase --abort err> /dev/null }
#       if (ls -D ([$dir ".git"] | path join) | get 0 | get type) == "dir" {
#         ^git -C $dir pull --rebase --no-gpg-sign
#       } else {
#         ^git -C $dir rebase --no-gpg-sign
#       }
#       let b = (git -C $dir rev-parse --abbrev-ref HEAD)
#       let remote = (git -C $dir rev-parse $"origin/($b)")
#       let local = (git -C $dir rev-parse $b)
#       print -e $"remote=($remote | str substring 0..6); local=($local | str substring 0..6)"
#       if ($local != $remote) {
#         ^git -C $dir push origin HEAD -f
#       }
#     }
#   }
# }

def "main pkgup" [...pkglist] {
  header "light_yellow_reverse" "pkgup"

  let pkgref = $"($env.PWD)#packages.x86_64-linux"
  let pkglist = if ($pkglist | length) == 0 {
    ^nix ...[eval
      --json $pkgref
      --apply 'x: builtins.attrNames x'
    ] | str trim | from json
  } else { $pkglist }

  print -e $pkglist

  for pkgname in $pkglist {
    header "light_yellow_reverse" $"pkgup: ($pkgname)"

    let flakepkg = $"($pkgref).($pkgname)"
    let t = $"/tmp/commit-msg-($pkgname)"
    rm -f $t
    ^nix-update [
      --flake
      --format
      --version "branch"
      --write-commit-message $t
      $pkgname
    ]

    try {
      main nfb --download true $flakepkg
      if ($t | path exists) and (open $t | str trim | str length) != 0) {
        git commit -F $t $"./pkgs/($pkgname)"
│     }
    } catch {
      print -e $"pkgup: ($pkgname): restoring/undoing"
      git restore $"./pkgs/($pkgname)"
    }
  }
}

def "main lockup" [] {
  header "light_yellow_reverse" "lockup"
  ^nix ...[ flake lock --recreate-lock-file --commit-lock-file ]
}

def "main nfb" [--download: bool = false --cache: bool = false buildable: string] {
  header "light_yellow_reverse" $"nfb: ($buildable)"
  # TODO: input reidrection breaks error handling: https://github.com/nushell/nushell/issues/11153
  ^nix-fast-build ...$builder.nfbargs --flake $buildable out> /tmp/x
  if ($env.LAST_EXIT_CODE != 0) {
    error make {msg: "nfb failed!"}
  }
  let res = open /tmp/x | split row -r '\n'
  let resp = ($res | str join (char newline))
  if ($cache or $download) {
    let res = $resp | ^ssh ($builder.host) "cachix push colemickens"
  }
  if $download {
    $resp | nix build --stdin --no-link -j0
  }
  $res
}

def "main dumpdeps" [ buildable: string ] {
  let res = ^nix-eval-jobs --flake $buildable | split row -r '\n' | each { |x| $x | from json }
  print -e $res
  let res2 = ($res | get inputDrvs)
  print -e $res2
  print -e ($res2 | to json)
}

def "main up" [...hosts] {
  # header "light_red_reverse" "up" "▒"

  main inputup
  main lockup
  main nfb --download true ".#devShells.x86_64-linux"
  main pkgup
  # we need to do both before and after because
  # devShells contains somethings that might've been bumped
  # if pkgup breaks, we want to still have as much devshell as possible though
  main nfb --download true ".#devShells.x86_64-linux"

  let all = main nfb --cache true ".#checks.x86_64-linux"
  main deploy zeph --toplevel ($all | find zeph | first)
  
  # NOTE: deploying other hosts is done in a github action
}

def main [] { main up }
