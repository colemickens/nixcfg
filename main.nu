#!/usr/bin/env nu

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def "main deploy" [ host: string, --toplevel: string = ""] {
  let target = (tailscale ip --4 $host | str trim)
  let toplevel = if $toplevel != "" { $toplevel } else {
    header "light_purple_reverse" $"deploy\(($host)\): build"
    let pth = (mktemp -d)
    mut res = ""
    try {
      $res = (^nix build -L --out-link $"($pth)/result" $".#toplevels.($host)")
      $res = (readlink -f $"($pth)/result")
      glob $"($pth)/result*" | to text | cachix push colemickens
      rm -rf $pth
    } catch {
      error make {msg: $"warning: something failed. may not have cachix push'd \(check ($pth)\)"}
    }
    $res | ansi strip
  }
  header "light_purple_reverse" $"deploy\(($host)\): start"

  header "light_blue_reverse" $"deploy\(($host)\): deploy ($toplevel)"
  let dl_cmd = (^printf "'%s' " ...[$"sudo" "nix" "build" "--no-link" "--accept-flake-config" "--option" "narinfo-cache-negative-ttl" "0" $"--profile" "/nix/var/nix/profiles/system" $toplevel ])
  let switch_cmd = (^printf "'%s' " ...[ "sudo" $"($toplevel)/bin/switch-to-configuration" "switch" ])
  let cmd = $"($dl_cmd) && ($switch_cmd)"
  ^ssh $"cole@($target)" -- $cmd

  if $"(^hostname)" == $host {
    header "light_green_reverse" $"deploy\(($host)\): fix-ssh-remote \(local\)"
    ^fix-ssh-remote
  }

  header "light_green_reverse" $"deploy\(($host)\): done"
  print -e $"(char nl)"
}

def "main selfup" [] {
  sudo nix build --accept-flake-config --profile "/nix/var/nix/profiles/system" $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

def "main up" [...hosts] {
  do {
    header "light_yellow_reverse" "update: cmpkgs"
    cd ../nixpkgs
    jj git fetch --all-remotes; jj rebase -b cmpkgs -d nixos-unstable@nixos --ignore-immutable; jj git push -b cmpkgs
  }
  do {
    header "light_yellow_reverse" "update: cmhm"
    cd ../home-manager
    jj git fetch --all-remotes; jj rebase -b cmhm -d master@nix-community --ignore-immutable; jj git push -b cmhm
  }

  header "light_yellow_reverse" "update: flake lock"
  nix flake update --commit-lock-file

  header "light_yellow_reverse" "update: bulk build"
  nix build --accept-flake-config --print-out-paths --keep-going '.#toplevels.zeph' '.#toplevels.slynux' '.#toplevels.raisin' | cachix push colemickens
  main deploy raisin
  main deploy slynux
  main deploy zeph

  header "light_purple_reverse" $"optimistic: build bundle"
  nix build --accept-flake-config --print-out-paths --keep-going '.#bundles.x86_64-linux.extra'
}

def main [] {
  print -e "run a command!"
}
