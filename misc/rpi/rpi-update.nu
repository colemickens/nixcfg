#!/usr/bin/env nu

let builder_arch = "x86_64-linux"
let cachedir = $"($env.HOME)/.cache/rpi"
mkdir $cachedir

let upstream = "nixos/nixos-unstable-small"
let upstream_pr = "nixos/master"
let branch = "rpipkgs"
let branch_pr = "rpi-updates-auto"
let branch_dev = "rpipkgs-dev"

let nixpkgs = $"~/code/nixpkgs/($branch)"
let nixpkgs_pr = $"~/code/nixpkgs/($branch_pr)"
let nixpkgs_dev = $"~/code/nixpkgs/($branch_dev)"

def update [] {
  print -e $"(ansi purple)update(ansi reset)"
  do -c { ^bash ./misc/rpi/update-rpi-packages.sh }
}

def pre [] {
  print -e $"(ansi purple)pre(ansi reset)"
  git -C $nixpkgs remote update
  git -C $nixpkgs worktree prune
  
  git -C $nixpkgs rebase --abort | ignore
  git -C $nixpkgs reset --hard $branch_dev
  git -C $nixpkgs rebase $upstream --no-gpg-sign
}

def post [] {
  print -e $"(ansi purple)post(ansi reset)"
  git -C $nixpkgs_pr rebase --abort | ignore
  git -C $nixpkgs_pr reset --hard $branch
  git -C $nixpkgs_pr rebase $upstream_pr --no-gpg-sign
  git -C $nixpkgs_pr push origin HEAD -f
  git -C $nixpkgs push origin HEAD -f
}

def buildall [] {
  print -e $"(ansi purple)build all(ansi reset)"
  let p = $"($nixpkgs)#legacyPackages.($builder_arch).pkgsCross.aarch64-multiplatform"
  let store = $"ssh-ng://($env.BUILDER_X86)"
  (^nix build
    --keep-going --no-link
    --eval-store auto
    --store $store
    $"($p).raspberrypifw"
    $"($p).raspberrypifw-master"
    $"($p).raspberrypiWirelessFirmware"
    $"($p).libraspberrypi"
    $"($p).raspberrypi-eeprom"
    $"($p).raspberrypi-armstubs"
    $"($p).linux_rpi4"
  )
}

pre
update
buildall
post
