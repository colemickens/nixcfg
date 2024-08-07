#!/usr/bin/env nu

let machines = [
  # unreliable, even without external disk
  # { name: "hcloud-arm64-dev1", vol: "vol-arm64-dev1-nbg", loc: "nbg1", type: "cax41", image: "ubuntu-24.04" },

  # semi-reliable without external disk:
  # { name: "hcloud-arm64-dev1", vol: "vol-arm64-dev1-nbg", loc: "nbg1", type: "cax21", image: "ubuntu-24.04" },

  # untested
  { name: "hcloud-arm64-dev1", vol: "vol-arm64-dev1-nbg", loc: "nbg1", type: "cax31", image: "ubuntu-24.04" },
  
  { name: "hcloud-amd64-dev1", vol: "vol-amd64-dev1-hil", loc: "hil", type: "ccx33", image: "ubuntu-24.04" },
]

def "main up" [name: string] {
  let row = ($machines | where {|m| $m.name == $name } | first)
  hcloud ...[
    server create
    --volume $row.vol
    --location $row.loc
    --name $row.name
    --image $row.image
    --type $row.type
    --ssh-key 'cardno:19_989_383'
  ]
}

def "main prov" [name: string] {
  let server = (^hcloud server describe $name -o json | from json)
  let server = $server.public_net.ipv4.ip
  nix run ...[
    github:nix-community/nixos-anywhere --
      --flake $".#($name)"
      $"root@($server)"
      --build-on-remote
      --option 'extra-substituters' 'https://colemickens.cachix.org'
      --option 'extra-trusted-public-keys' 'colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4='
  ]
  # nixos-anywhere --flake $".#($name)" $"root@($server)" --build-on-remote
}

def "main down" [name: string] {
  hcloud ...[
    server delete $name
  ]
}

def "main try" [name: string] {
  do -i { main down $name }
  main up $name
  main prov $name
}

def main [] {
  print -e "./boot.nu [up|down]"
}
