#!/usr/bin/env nu

source _common.nu

def "main" [] {
  print "::group::info"
  nix --version
  print "::endgroup"

  let url = $"git@github.com:colemickens/nixcfg"
  let dir = $"($ROOT)/nixcfg"
  mkdir $dir

  print "::group::init"
  do {
    cd $dir
    git remote set-url origin $url

    git remote update
    do -i { git rebase --abort }

    git switch -C main-next-wip
    git reset --hard origin/main
    git push origin HEAD -f
  }


  print -e ">>> next: nixpkgs (cmpkgs)"

  let url = $"git@github.com:colemickens/nixpkgs"
  let dir = $"($ROOT)/nixpkgs"
  
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

  print -e ">>> next: home-manager (cmhm)"

  let url = $"git@github.com:colemickens/home-manager"
  let dir = $"($ROOT)/home-manager"
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
  print "::endgroup"

  do {
    cd $"($ROOT)/nixcfg"

    let start = (date now)
    print -e $">>> nix flake update \(start\) ($start)"

    ^nix ...[
      flake update
      --accept-flake-config
      --commit-lock-file
      --override-input cmpkgs github:colemickens/nixpkgs/cmpkgs-next-wip
      --override-input home-manager github:colemickens/home-manager/cmhm-next-wip
    ]

    let duration = (date now) - $start
    print -e $">>> nix flake update \(done\) (date now) - ($duration)"

    git push origin HEAD
  }
}