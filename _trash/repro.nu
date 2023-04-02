#!/usr/bin/env nu

def "main inputup" [] {
  let srcdirs = [ "good" "bad" "good2" ]

  for i in $srcdirs {
    print -e $"[inputup] attempting ($i)"
    # if ($i == "bad") { 
      print -e $"[inputup] intentionally calling ^false for [($i)]"
      ^false
      print -e $"[inputup] somehow survived ^false for [($i)]"
    # }
    print -e $"[inputup] success for [($i)]"
  }

  print -e $"[inputup] finished"
}

def indirection [] {
  main inputup
  print -e "[indirection] survived after inputup"
}

def main [] {
  indirection
  print -e "[main] surived after inputup"
}
