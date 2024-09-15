#!/usr/bin/env nu

# TODO:
# - follow up on self-hosted runners being weird about HOME + sshkeys
# - figure out a strategy for pinning the most recent build with a gcroot so we can enable GC again
let ROOT = ([$env.FILE_PWD "../.." ] | path join)
let gcrootdir = $"($ROOT)/_gcroots"

git config --global user.name 'Cole Botkens'
git config --global user.email 'cole.mickens+colebot@gmail.com'

$env.CACHIX_SIGNING_KEY = (try { open "/run/secrets/cachix_signkey_colemickens" } catch { "" })

let nfbflags = [
  --no-nom
  --eval-workers 1 # we keep getting killed in the GHA (on raisin) :(
  --eval-max-memory-size 4096
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
  "100.81.167.123 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtqJfWwWtcxeWHKwjbY34VHnp79PGcjS9g21WRuJKdo"
  # raisin
  "100.112.194.64 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFL0c9gNJWpGPyyQgWLbao6zSNMAMFDmwQQGHeOcVCU"
  # rock5b
  "100.118.5.4 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJzIZu1IiwNvioKhw59hmH46SfUSDBUPqoVffCEQFDOY"
  "100.118.5.4 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCZl8BBtLiyPbM2WXUn+RTTbeQdL3bTvrR+HBVxK1yTNzFP+BlSfJ7jLDXq+jjlXSZsLrOfDED7RVPFJUV/hm+RfXi5RCxaTqA8GovN2qCAR+ghwFdigN9cKXKWOXjDNZpECWpANHROBdkWSremPb/SSmF3r6j2P2L6HGi2mYGjHrAliNHjzSNByIgmc02HMOdEhyIRmYYFhv7HqB4RS8wrcyFSwbSSRmL3KpVokzel6dMjI13mBrNIZiHsA/tseqQg8h1bT1/Jjw2B9xDRdebx1ZFsRqAAguQP14HtkF4OtwgCwOf4RUf2pyK+MaameIce54/47W50Ru2qrqxPkM3tV2iKhwFkrWuUWhNuzAOQhnXACZNKs8Q17REB2Uua7ZO2XzE+Mzr0UUVVE5YCNh/JFtaBT8YGm7CcIj/8U81MeDAQcndXFNWzbSbk6V/60LEUDDuykLSSlPvvkTILTdHhr1JYhttev8owlFZjSWsQbxfBUIRtSSRtHwTd0dtPLMzc+tglKXwgXQoRlibrUk8a/pdZLoPmAT1sAygBnlMKtADY8vh6E+TbFz1meh7qVKfp5XxPlMiYhuxSOFzHtwTogRQoLsPSPe0eYp2tlMDK+X50HnhjpyUWw8iFBnt/ObwtglZlWgP5xrQbcVzqIo6bOeEGuBoF6D49SgBNH7H16Q=="
  # h96maxv58
  "100.92.31.121 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQnNVQll/2H6voaRP76v7qsjhHCe38BSZchYtJ2MSia"
] | save -a $ssh_hosts

let runid = $"($env.GITHUB_RUN_ID)-($env.GITHUB_RUN_NUMBER)-($env.GITHUB_RUN_ATTEMPT)"

let sshargs = [ "-i" "/run/secrets/github-colebot-sshkey" "-o" $"UserKnownHostsFile=($env.HOME)/.ssh/known_hosts" ]
$env.GIT_SSH_COMMAND = $"ssh ($sshargs | str join ' ')"

def "main deploy" [host: string --activate = true] {
  ls -al .latest | print -e

  let out = open $".latest/result-x86_64-linux.($host)"
  let addr = ^tailscale ip --4 $host
  print -e $"deploy ($out) to ($addr)"

  if (not $activate) {
    ^ssh ...$sshargs $"cole@($addr)" $"sudo nix build -j0 --no-link ($out)"
    return
  }

  ^ssh ...$sshargs $"cole@($addr)" $"sudo nix build -j0 --no-link --profile /nix/var/nix/profiles/system ($out)"
  ^ssh ...$sshargs $"cole@($addr)" $"sudo ($out)/bin/switch-to-configuration switch"
}

def "main update" [] {
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

    ^nix ...[
      flake lock
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
      print -e $"::group::pkgup ($pkgname)"
      do {
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
      print "::endgroup"
    }
  }

  ## NIX-FAST-BUILD
  print "::group::nfb"
  try {
    env NIXPKGS_ALLOW_UNFREE=1 nix build --impure '.#pkgs.x86_64-linux.pkgsCross.aarch64-multiplatform.mongodb-6_0' --option cores 4
    nix-fast-build ...$nfbflags
  } catch {
    ls -l result* | print -e
    ^ls -d result* | cachix push colemickens
    print -e "::warning::nix-fast-build failed, but we cached something"
    exit -1
  }
  print "::endgroup"

  print "::group::cachix push"
  do {
    ^ls -d result* | ^tee "/dev/stderr" | cachix push colemickens
  }
  print "::endgroup"

  # collect results
  print "::group::save results"
  do {
    git switch -C 'main-next-results'
    rm -rf .latest/
    mkdir .latest/
    rm -rf $gcrootdir
    mkdir $gcrootdir
    
    
    let results = (ls -l result-*)
    for res in $results {
      let filename = $".latest/($res.name)"
      print -e $"saving ($res.target) in ($filename)"
      $res.target | save $filename
      nix build -j0 --out-link $"($gcrootdir)/($res.name)" $res.target
    }
  }
  print "::endgroup"

  print "::group::git commit-push"
  do {
    ^git add -f ./.latest
    ^git commit -m $".latest: latest build results ($runid)" ./.latest
    git push origin HEAD -f
  }
  print "::endgroup"

  ## NOW UPDATE BRANCHES
  print "::group::git update branches"
  do {
    cd $"($ROOT)/nixpkgs"
    git switch -C cmpkgs-next
    git reset --hard origin/cmpkgs-next-wip
    git push origin HEAD -f
  }
  do {
    cd $"($ROOT)/home-manager"
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
      --commit-lock-file
      --override-input cmpkgs github:colemickens/nixpkgs/cmpkgs-next
      --override-input home-manager github:colemickens/home-manager/cmhm-next
    ]

    git push origin HEAD -f
  }
  print "::endgroup"
}

def main [] {
  print -e "use [deploy,update] subcommands"
}
