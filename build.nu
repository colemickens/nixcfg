#!/usr/bin/env nu

source ./lib.nu

def main [ drvRef = "ciJobs.x86_64-linux.default": string] {
  buildDrv $drvRef
}
