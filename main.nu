#!/usr/bin/env nu

def "main deploy" [ host: string ] {
  let toplevel = (^nix eval --raw $".#nixosConfigurations.($host).config.system.build.toplevel")
  let dl_cmd = (^printf "'%s' " ...[$"sudo" "nix" "build" "--no-link" "--accept-flake-config" "--option" "narinfo-cache-negative-ttl" "0" $"--profile" "/nix/var/nix/profiles/system" $toplevel ])
  let switch_cmd = (^printf "'%s' " ...[ "sudo" $"($toplevel)/bin/switch-to-configuration" "switch" ])
  let cmd = $"($dl_cmd) && ($switch_cmd)"
  ^ssh $"cole@($host)" -- $cmd

  header "light_green_reverse" $"deploy\(($host)\): done"
  print -e $"(char nl)"
}

def "main nixos selfup" [] {
  sudo nix build --accept-flake-config --profile "/nix/var/nix/profiles/system" $".#toplevels.(^hostname | str trim)"
  sudo ./result/bin/switch-to-configuration switch
}

def "main darwin selfup" [] {
  sudo darwin-rebuild --flake /Users/cole/code/nixcfg
}

def main [] {
  print -e "run a command!"
}
