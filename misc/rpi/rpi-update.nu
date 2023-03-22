#!/usr/bin/env nu

let builder_arch = "x86_64-linux"
let cachedir = $"($env.HOME)/.cache/rpi"
mkdir $cachedir

#
# pre
print -e $"(ansi purple)pre(ansi reset)"
let mb = (^git -C ~/code/nixpkgs/master merge-base cmpkgs cmpkgs-rpipkgs | str trim)
let cc = (^git -C ~/code/nixpkgs/master show-ref refs/heads/cmpkgs -s | str trim)
git -C ~/code/nixpkgs/master remote update
git -C ~/code/nixpkgs/master worktree prune

git -C ~/code/nixpkgs/rpipkgs rebase --abort | ignore
git -C ~/code/nixpkgs/rpipkgs rebase 'nixos/nixos-unstable-small' --no-gpg-sign

let last_ref = (^git show-ref refs/heads/rpipkgs | str trim)

#
# do work
print -e $"(ansi purple)update(ansi reset)"
do -c { ^bash ./misc/rpi/update-rpi-packages.sh }

#
# sanity check our work
print -e $"(ansi purple)build all(ansi reset)"
let p = $"($env.HOME)/code/nixpkgs/rpipkgs#legacyPackages.($builder_arch).pkgsCross.aarch64-multiplatform"
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
  $"($p).linux_rpi4")

#
# post
print -e $"(ansi purple)post(ansi reset)"
let new_ref = (^git show-ref refs/heads/rpipkgs | str trim)
let should_update = (
  if ($last_ref != $new_ref) {
    print -e $"(ansi purple)new commits, rebasing cmpkgs-rpipkgs(ansi reset)"
    true
  } else if ($mb != $cc) {
    print -e $"(ansi purple)merge base moved, rebasing cmpkgs-rpipkgs(ansi reset)"
    true
  } else {
    false
  }
)

if ($should_update) {
  git -C ~/code/nixpkgs/cmpkgs-rpipkgs rebase --abort | ignore
  git -C ~/code/nixpkgs/cmpkgs-rpipkgs reset --hard rpipkgs
  git -C ~/code/nixpkgs/cmpkgs-rpipkgs rebase cmpkgs --no-gpg-sign
  git -C ~/code/nixpkgs/cmpkgs-rpipkgs push origin HEAD -f
} else {
  print -e $"(ansi purple)skipping rebase(ansi reset)"
}

