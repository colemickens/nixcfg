#!/usr/bin/env nu

source ./lib.nu

def main [ drvRef: string] {
  buildDrv $drvRef
}
