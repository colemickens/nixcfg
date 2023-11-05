#!/usr/bin/env nu

let groups = [
  [ "1a" "1b" ]
  [ "2a" "2b" ]
]

$groups | par-each { |group|
  for g in $group {
    print -e $"here with ($g)"
    if ($g == "1b") {
      ^false
    }
    print -e $"fell-through with ($g)"
  }
}

print -e "survived"
