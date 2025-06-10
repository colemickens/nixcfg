#!/usr/bin/env nu

def header [ color: string text: string spacer="▒": string ] {
  let text = $"("" | fill -a r -c $spacer -w 2) ($text | fill -a l -c ' ' -w 80)"
  print -e $"(ansi $color)($text)(ansi reset)"
}

def "main deploy" [ host: string, --toplevel: string = ""] {
  let target = (tailscale ip --4 $host | str trim)
  let toplevel = if $toplevel != "" { $toplevel } else {
    let res = nix build --print-out-paths $".#toplevels.($host).outPath"
    $res | ansi strip
  }
  header "light_purple_reverse" $"deploy: start: ($host)"

  header "light_blue_reverse" $"deploy: profile dl: ($host): ($toplevel)"
  let dl_cmd = (^printf "'%s' " ...[$"sudo" "nix" "build" "--no-link" "--accept-flake-config" $"--profile" "/nix/var/nix/profiles/system" $toplevel ])
  let switch_cmd = (^printf "'%s' " ...[ "sudo" $"($toplevel)/bin/switch-to-configuration" "switch" ])
  let cmd = $"($dl_cmd) && ($switch_cmd)"

  print -e $"(ansi grey)running cmd: ($cmd)(ansi reset)"
  ^ssh $"cole@($target)" -- $cmd

  header "light_green_reverse" $"deploy: ($host): DONE"
  print -e $"(char nl)"
}

def "main selfup" [] {
  sudo nix build --profile "/nix/var/nix/profiles/system" $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

def "main up" [...hosts] {
  nix flake update --commit-lock-file
  nix build --print-out-paths '.#toplevels.zeph' '.#toplevels.slynux' '.#toplevels.raisin' | cachix push colemickens
  main deploy raisin
  main deploy slynux
  main deploy zeph
}

def "main nix" [...args] {
  ^nix $args
}

def main [] {
  print -e "run a command!"
}
