#!/usr/bin/env nu

let machines = [
  { name: "hcloud-arm64-dev1", vol: "vol-arm64-dev1-nbg", loc: "nbg1", type: "cax41", image: "ubuntu-24.04" },
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
  nix run github:nix-community/nixos-anywhere -- --flake $".#($name)" $"root@($server)" --build-on-remote
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
