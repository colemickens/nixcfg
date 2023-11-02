#!/usr/bin/env nu

# TODO:
# - follow up on self-hosted runners being weird about HOME + sshkeys
# - figure out a strategy for pinning the most recent build with a gcroot so we can enable GC again

git config --global user.name 'Cole Botkens'
git config --global user.email 'cole.mickens+colebot@gmail.com'

$env.CACHIX_SIGNING_KEY = (open "/run/secrets/cachix_signkey_colemickens")

let ssh_hosts = $"($env.HOME)/.ssh/known_hosts"
mkdir $"($env.HOME)/.ssh"
rm -f $ssh_hosts
[
  "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
  "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
] | save -a $ssh_hosts

# print "XXXXXXXXXXXXXXXXX"
# echo $ssh_hosts
# cat $ssh_hosts
# print "XXXXXXXXXXXXXXXXX"

$env.GIT_SSH_COMMAND = $"ssh -i /run/secrets/github-colebot-sshkey -o UserKnownHostsFile=($env.HOME)/.ssh/known_hosts"

let ROOT = ([$env.FILE_PWD "../" ] | path join)

let url = $"git@github.com:colemickens/nixcfg"
let dir = $"($ROOT)/nixcfg"
mkdir $dir
do {
  cd $dir
  git remote set-url origin $url

  git remote update
  # TODO: avoid this so we sorta have GC roots for a bit?
  # without stashing them in a dir and cleaning up, we can end up with orphan old ones
  # git clean -xdf
  do -i { git rebase --abort }

  git switch -C main-next-wip
  git reset --hard origin/main
  git push origin HEAD -f
}

let url = $"git@github.com:colemickens/nixpkgs"
let dir = $"($ROOT)/nixpkgs/cmpkgs"
mkdir $dir
do {
  cd $dir
  do -i { git init }
  do -i { git remote add origin $url }
  do -i { git remote set-url origin $url }
  git remote update
  do -i { git rebase --abort }

  git switch -C cmpkgs-next-wip
  git reset --hard origin/cmpkgs

  do -i { git remote add nixos https://github.com/nixos/nixpkgs }
  git remote update
  git rebase nixos/nixos-unstable

  git push origin HEAD -f
}

let url = $"git@github.com:colemickens/home-manager"
let dir = $"($ROOT)/home-manager/cmhm"
mkdir $dir
do {
  cd $dir
  do -i { git init }
  do -i { git remote add origin $url }
  do -i { git remote set-url origin $url }
  git remote update
  do -i { git rebase --abort }

  git switch -C cmhm-next-wip
  git reset --hard origin/cmhm

  do -i { git remote add nix-community https://github.com/nix-community/home-manager }
  git remote update
  git rebase nix-community/master

  git push origin HEAD -f
}

do {
  cd $"($ROOT)/nixcfg"

  ^nix [
    flake lock
    --recreate-lock-file
    --commit-lock-file
    --override-input cmpkgs github:colemickens/nixpkgs/cmpkgs-next-wip
    --override-input home-manager github:colemickens/home-manager/cmhm-next-wip
  ]

  git push origin HEAD
}

## PKGUP

do {
  cd $"($ROOT)/nixcfg"

  let pkgref = $"($env.PWD)#packages.x86_64-linux"
  let pkglist = ^nix [
    eval
    --json $pkgref
    --apply "x: builtins.attrNames x"
  ] | str trim | from json

  for pkgname in $pkglist {
    try {
      ^nix-update [
        --flake
        --build
        --commit
        --format
        --version branch
        $pkgname
      ]

      git push origin HEAD
      print -e $"pushed ($pkgname)"
    } catch {
      git restore $"./pkgs/($pkgname)"
      print -e $"pkgup: ($pkgname): restoring/undoing"
    }
  }
}

## NIX-FAST-BUILD

nix-fast-build --no-nom
^ls -d result* | cachix push colemickens


## NOW UPDATE BRANCHES
do {
  cd $"($ROOT)/nixpkgs/cmpkgs"
  git switch -C cmpkgs-next
  git reset --hard origin/cmpkgs-next-wip
  git push origin HEAD -f
}
do {
  cd $"($ROOT)/home-manager/cmhm"
  git switch -C cmhm-next
  git reset --hard origin/cmhm-next-wip
  git push origin HEAD -f
}

do {
  cd $"($ROOT)/nixcfg"
  git switch -C main-next
  git reset --hard main-next-wip

  ^nix [
    flake lock
    --recreate-lock-file 
    --commit-lock-file
    --override-input cmpkgs github:colemickens/nixpkgs/cmpkgs-next
    --override-input home-manager github:colemickens/home-manager/cmhm-next
  ]

  git push origin HEAD -f
}
