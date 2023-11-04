#!/usr/bin/env nu

def main [host: string] {
  let out = (open $".latest/result-nixos-system-($host)*")
  let addr = ^tailscale ip --4 $host
  echo -e $"deploy ($out) to ($host)"
}
