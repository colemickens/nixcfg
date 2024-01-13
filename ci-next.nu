#!/usr/bin/env nu

# TODO:
# - follow up on self-hosted runners being weird about HOME + sshkeys
# - figure out a strategy for pinning the most recent build with a gcroot so we can enable GC again
let ROOT = ([$env.FILE_PWD "../" ] | path join)
let gcrootdir = $"($ROOT)/_gcroots"

git config --global user.name 'Cole Botkens'
git config --global user.email 'cole.mickens+colebot@gmail.com'

$env.CACHIX_SIGNING_KEY = (open "/run/secrets/cachix_signkey_colemickens")

let nfbflags = [
  --no-nom
  --eval-workers 1 # we keep getting killed in the GHA (on raisin) :(
]

let ssh_hosts = $"($env.HOME)/.ssh/known_hosts"
mkdir $"($env.HOME)/.ssh"
rm -f $ssh_hosts
[
  # github host keys - used to push -next{,-wip} branches to github
  "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
  "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="

  # per-host host keys - used to (download paths | deploy) to a given host
  # zeph
  "100.109.239.83 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8xzm2cJvb/6bLBjVaMsFHc50BOUQdcQv7EZgvk8QR8"
  # slynux
  "100.85.243.118 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWb7+dSGw/St8AGhtoSOlnDIfTjQGEJ6mWuOv49hFpA"
  # raisin
  "100.112.194.64 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFL0c9gNJWpGPyyQgWLbao6zSNMAMFDmwQQGHeOcVCU"
  # xeep
  "100.72.11.62 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzCYIpoxOMwsHMKGTcpmtAuu+yTfkP6ZhaF/YjWAzFI"
  # openstick
  "100.121.148.102 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUYISzsaKXXf0OTojyzpbsA8M4p9+DjQ+PHZ2aLUrT6"
  "100.121.148.102 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfYSjPHl9PERzgJ1G5iPj431YKO1PvBGfpGfvOQekAWcdnD0s7eY/cAfTnGZ9C3+z/5stXx6XCPL683rk8SacvHVENIpfccZUyXNsruRUDiVFvJrZLX9jZDbREPxIXHRI0pckcLp4S43+ogzkD9B+7yTBe3h48vA+DMubXT3Gk72z/HUSfOFeJqRb9HpNtMa8+F6MAjk1BOaL62IJBekI5qTJV/r+6eWxfq11hIs1ADuawhqu2/c6ATMD4ILb/qa4F+sPDCHlnxz+wlOkqyKRoyf48JLJE4jJx3Vo4Za90YOAOpTxz2NRQTMzMvtTiFxg2NDLF4AB2We1dzzlGiNayi2cZsD9xQxGvmzrZhk1JW17XIcH9e04gH9GafGH74t3v5Jkrri4Q4wHD3tri8MSgMctH9cQ2SzEEQHlu02vSGIaEGR/akXzixq1ymPNUy49IdxudNCKxjEFiO95WagTD+s/bn91ex633h8/ay9JS20omsXGJYYZIzmKOTS32um0uoIhh5FozKi+yKiZ8/ZiGgnm+gC7ZzIxK91Q1OR41wfTQZ+6ABsaCcGjpjH38loTiI3dy/duBYlwLFTGsiV1GbKJuhVDKuEKzm2TADxvnv6FffYQ0tvSFTz+UTEzqzxMaFLYhFoX28Eml1cwH7+4Z7/lB9HlU4xJQbcamTEDtKQ=="
] | save -a $ssh_hosts

let runid = $"($env.GITHUB_RUN_ID)-($env.GITHUB_RUN_NUMBER)-($env.GITHUB_RUN_ATTEMPT)"

let sshargs = [ "-i" "/run/secrets/github-colebot-sshkey" "-o" $"UserKnownHostsFile=($env.HOME)/.ssh/known_hosts" ]
$env.GIT_SSH_COMMAND = $"ssh ($sshargs | str join ' ')"

def "main extra" [] {
  print -e "doing extra things"
}

def "main deploy" [host: string --activate: bool = true] {
  ls -al .latest | print -e

  let out = open $".latest/result-x86_64-linux.toplevel-($host)"
  let addr = ^tailscale ip --4 $host
  print -e $"deploy ($out) to ($addr)"

  if (not $activate) {
    ^ssh ...$sshargs $"cole@($addr)" $"sudo nix build -j0 --no-link ($out)"
    return
  }

  ^ssh ...$sshargs $"cole@($addr)" $"sudo nix build -j0 --no-link --profile /nix/var/nix/profiles/system ($out)"
  ^ssh ...$sshargs $"cole@($addr)" $"sudo ($out)/bin/switch-to-configuration switch"

  # TODO: better way to do per-host post-deploy commands
  if $host == "openstick" {
    do -i {
      print -e "rebooting openstick"
      ^ssh ...$sshargs $"cole@($addr)" "nix-env --profile ~/.local/state/nix/profiles/home-manager --delete-generations +1"
      ^ssh ...$sshargs $"cole@($addr)" "sudo reboot"
    }
  }
}

def "main update" [] {
  let url = $"git@github.com:colemickens/nixcfg"
  let dir = $"($ROOT)/nixcfg"
  mkdir $dir
  do {
    cd $dir
    git remote set-url origin $url

    git remote update
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

    ^nix ...[
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
    let pkglist = ^nix ...[
      eval
      --json $pkgref
      --apply "x: builtins.attrNames x"
    ] | str trim | from json

    for pkgname in $pkglist {
      try {
        ^nix-update ...[
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

  try {
    nix-fast-build ...$nfbflags
  } catch {
    ls -l result* | print -e
    ^ls -d result* | cachix push colemickens
    print -e "nix-fast-build failed, but we cached something"
    exit -1
  }
  ^ls -d result* | cachix push colemickens

  # collect results
  rm -rf .latest/
  mkdir .latest/
  rm -rf $gcrootdir
  mkdir $gcrootdir
  let results = (ls -l "result-*")
  for res in $results {
    let filename = $".latest/($res.name)"
    print -e $"saving ($res.target) in ($filename)"
    $res.target | save $filename
    nix build -j0 --out-link $"($gcrootdir)/($res.name)" $res.target
  }
  ^git add -f ./.latest
  ^git commit -m $".latest: latest build results ($runid)" ./.latest
  git push origin HEAD

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

    ^nix ...[
      flake lock
      --recreate-lock-file 
      --commit-lock-file
      --override-input cmpkgs github:colemickens/nixpkgs/cmpkgs-next
      --override-input home-manager github:colemickens/home-manager/cmhm-next
    ]

    git push origin HEAD -f
  }
}

def main [] {
  print -e "use [deploy,update] subcommands"
}
