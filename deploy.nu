#!/usr/bin/env nu

source ./lib.nu

def main [ host = "": string ] {
  if $host == "" {
    # TODO: dynamic
    [ "slynux" "carbon" "raisin" "xeep" "jeffhyper" ]
    | each { |h| deploy $h }
  } else {
    deploy $host
    null
  }
}
