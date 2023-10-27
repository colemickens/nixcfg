#!/usr/bin/env nu

do {
  let list1 = [1 2]
  for i in list1 {
    try {
      (./test-errors-inner.sh
        "run1: thisisanarg")
      print -e "run1: fellthrough"
    } catch {
      print -e "run1: caught it"
    }
  }
}

do {
  let list1 = [1 2]
  for i in list1 {
    try {
      ./test-errors-inner.sh "run2: thisisanarg"
      print -e "run2: fellthrough"
    } catch {
      print -e "run2: caught it"
    }
  }
}
