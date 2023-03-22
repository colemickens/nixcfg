#!/usr/bin/env nu

def "main inputup" [] {
  inputup
}

def inputup [] {
  let srcdirs = [ "a" "b" ]

  # $srcdirs | each { |dir|
  for dir in $srcdirs {
    print -e $"($dir): attempt"
    if ($dir == "a") { 
      # assumption 1: this will short circuit the 'each' and
      # result in this loop body NOT executing for subsequent entries, ex "b".
      # assumption 1: DOES NOT hold true, and might be by design?????
      # if so, I think it should be called out w/ explicit example if not already
      print -e $"($dir): false passed"
      ^false
      print -e $"($dir): after false [this isn't printed]"
    }
    # assumption 2: this will not be executed, certainly for "a"
    # assumption 2: HOLDS TRUE
    print -e $"($dir): fallthrough"
  }
}
# def "main indirect1" [] {
#   print -e "noop"
#   main inputup
#   print -e "surived after inputup (indirect1)"
# }
def main [] {
  # main indirect1
  main inputup
  # assumption 3: this will not be reached
  print -e "surived after inputup (main)"
}
