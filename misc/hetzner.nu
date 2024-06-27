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

def "main down" [name: string] {
  hcloud ...[
    server delete $name
  ]
}

def main [] {
  print -e "./boot.nu [up|down]"
}
