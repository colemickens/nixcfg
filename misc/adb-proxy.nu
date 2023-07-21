#!/usr/bin/env nu

loop {
  let c = (adb forward --list | str trim | str length)
  if $c == 0 {
    do -i {
      adb forward tcp:1088 tcp:1088
    }
  }
  sleep 1sec
}

# TODO: nushell trap exit??
