#!/usr/bin/env nu

source ./lib.nu

def main [  host = "_pc": string ] {
  deploy $host
}
