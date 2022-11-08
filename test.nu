#!/usr/bin/env nu


mkdir /tmp

def f1 [] {
  # ^false
  ^nix-eval-jobs --flake "poop"
  print -e $"exit=($env.LAST_EXIT_CODE)"
  
}

def main [] {
  print -e "main"
  f1
}
