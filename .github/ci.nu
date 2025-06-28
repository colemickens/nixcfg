#!/usr/bin/env nu

####################################################################################
let ROOT = ([$env.FILE_PWD "../.." ] | path join)
let gcrootdir = $"($ROOT)/_gcroots"

git config --global user.name 'Cole Botkens'
git config --global user.email 'cole.mickens+colebot@gmail.com'

$env.CACHIX_SIGNING_KEY = (try { open "/run/secrets/cachix_signkey_colemickens" } catch { "" })

let ssh_hosts = $"($env.HOME)/.ssh/known_hosts"
mkdir $"($env.HOME)/.ssh"
rm -f $ssh_hosts
cp $"($ROOT)/nixcfg/hosts/known_hosts" $ssh_hosts
[
  # github host keys - used to push -next{,-wip} branches to github
  "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
  "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
] | save -a $ssh_hosts

let sshargs = [ "-i" "/run/secrets/github-colebot-sshkey" "-o" $"UserKnownHostsFile=($env.HOME)/.ssh/known_hosts" ]
$env.GIT_SSH_COMMAND = $"ssh ($sshargs | str join ' ')"
####################################################################################

def "main info" [] {
  print -e "$ `nix --version`"
  nix --version
}

def "main build" [] {
  let thing = ".#bundle.x86_64-linux"

  mut success = false

  try {
    nix build -L --keep-going --accept-flake-config $thing
    $success = true
  }

  if not $success {
    try {
      print -e "::warning::we failed to build the first time, trying again"
      nix build -L -j1 --keep-going --accept-flake-config $thing
      $success = true
    }
  }

  if not $success {
    # NOTE: this is probably useless now that we're back to builing the whole bundle
    # instead of how nix-eval-jobs recurses
    ls -l result* | print -e
    ^ls -d result* | cachix push colemickens
    print -e "::warning::build failed, but we cached something"
    exit -1
  }

  do {
    ^ls -d result* | ^tee "/dev/stderr" | cachix push colemickens
  }
}

def "main next" [] {
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

def main [] {
  print -e "run a command!"
}
