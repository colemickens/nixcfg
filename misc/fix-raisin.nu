#!/usr/bin/env nu

let top = (^nix eval --raw '.#toplevels.raisin')
let r = (^tailscale ip --4 raisin)
let sshopts = [ "-o" "ConnectTimeout=5" ]

loop {
  print -e $">> try deploy ($top) to ($r)"
  do -i {
    ^ssh $sshopts $"cole@($r)" $"nix-store -r ($top)"
    ^ssh $sshopts $"cole@($r)" $"nix build --no-link --profile /nix/var/nix/profiles/system -j 0 ($top)"
    ^ssh $sshopts $"cole@($r)" $"sudo ($top)/bin/switch-to-configuration switch"
  }

  print -e ">> sleep 10sec"
  sleep 10sec
}
