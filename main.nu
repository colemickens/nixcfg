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
    nfbargs: [
      --remote $host
      --eval-workers 1
      --eval-max-memory-size 8096
      --no-nom
      --no-download
    ],
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

def "main deploy" [ host: string, --activate = true, --toplevel: string = ""] {
  let target = (tailscale ip --4 $host | str trim)
  let toplevel = if $toplevel != "" { $toplevel } else {
    let res = main nfb --cache true $".#toplevels.($host)"
    # $res | find $host | ansi strip | first
    $res | ansi strip
  }
  header "light_purple_reverse" $"deploy: start: ($host)"

  header "light_blue_reverse" $"deploy: profile dl: ($host): ($toplevel) ($activate)"
  # TODO: better way to interop into shellex?
  let cmd = (^printf "'%s' " ...[
    $"sudo" "nix" "build" "--no-link" "-j0" ...$nixflags
    "--option" "narinfo-cache-negative-ttl" "0"
    $"--profile" "/nix/var/nix/profiles/system" $toplevel
  ])
  let cmd = (if (not $activate) { $cmd } else {
    let $switch_cmd = (^printf "'%s' " ...[ "sudo" $"($toplevel)/bin/switch-to-configuration" "switch" ])
    $"($cmd) && ($switch_cmd)"
  })
  print -e $"(ansi grey)running cmd: ($cmd)(ansi reset)"

  ^ssh $"cole@($target)" -- $cmd
  header "light_green_reverse" $"deploy: ($host): DONE"
  print -e $"(char nl)"

  let hostname = (^hostname);
  if $hostname == $host {
    ^fix-ssh-remote
  }
}

############### Internal lib #################

def "main nix" [...args] {
  ^nix $nixflags $args
}

def "main selfup" [] {
  sudo nix build --profile "/nix/var/nix/profiles/system" $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

# TODO: replace with `jj run` in the future
# def "main inputup" [] {
#   header "light_yellow_reverse" "inputup"
#   let srcdirs = ([
#     "nixpkgs/master" "nixpkgs/nixos-unstable" "nixpkgs/cmpkgs"
#     "home-manager/master" "home-manager/cmhm"
#     "mobile-nixos/development" "mobile-nixos/development-flakes" "mobile-nixos/openstick"
#   ] | each { |it1| $it1 | each {|it| $"($env.HOME)/code/($it)" } })

#   for dir in $srcdirs {
#     if (not ($dir | path exists)) {
#       print -e $"(ansi yellow_dimmed)inputup: skip:(ansi reset) ($dir)"
#       continue
#     }
#     print -e $"(ansi yellow_dimmed)inputup: check:(ansi reset) ($dir)"
#     do -i { ^git -C $dir rebase --abort err> /dev/null }
#     if (ls -D ([$dir ".git"] | path join) | get 0 | get type) == "dir" {
#       ^git -C $dir pull --rebase --no-gpg-sign
#     } else {
#       ^git -C $dir rebase --no-gpg-sign
#     }
#     let b = (git -C $dir rev-parse --abbrev-ref HEAD)
#     let remote = (git -C $dir rev-parse $"origin/($b)")
#     let local = (git -C $dir rev-parse $b)
#     print -e $"remote=($remote | str substring 0..6); local=($local | str substring 0..6)"
#     if ($local != $remote) {
#       ^git -C $dir push origin HEAD -f
#     }
#   }
# }

def "main lockup" [] {
  header "light_yellow_reverse" "lockup"
  ^nix ...[ flake lock --recreate-lock-file --commit-lock-file ]
}

def "main nfb" [--download = false --cache = false buildable: string] {
  header "light_yellow_reverse" $"nfb: ($buildable)"
  # TODO: input reidrection breaks error handling: https://github.com/nushell/nushell/issues/11153
  let tmpfile = (^mktemp)
  ^nix-fast-build ...$builder.nfbargs --flake $buildable out> $tmpfile
  if ($env.LAST_EXIT_CODE != 0) {
    error make {msg: "nfb failed!"}
  }
  let resp = open $tmpfile | split row -r '\n' | str join (char newline)
  rm $tmpfile
  print -e "fooo"
  print -e $resp
  print -e "fooo"
  if ($cache or $download) {
    $resp | ^ssh ($builder.host) "cachix push colemickens"
  }
  if $download {
    $resp | nix build --stdin --no-link -j0
  }
  $resp
}

def "main loopup" [] {
  loop {
    try {
      print -e "recreate lock"
      nix flake lock --recreate-lock-file
      
      print -e "build checks1"
      nix-fast-build --eval-workers 1 -j 1 -f '.#checks1.x86_64-linux'
      print -e "build checks2"
      nix-fast-build --eval-workers 1 -j 1 -f '.#checks2.x86_64-linux'
    }
    sleep 10sec;
  }
}

def "main up" [...hosts] {
  jj git fetch --all-remotes
  main lockup

  main nfb --download true ".#devShells.x86_64-linux"
  main nfb --download true ".#checks-native.x86_64-linux"

  main deploy raisin
  main deploy slynux
  main deploy zeph

  main nfb --download true ".#checks-cross.x86_64-linux"
  main deploy h96maxv58
  main deploy rock5b
}

def main [] { main up }

