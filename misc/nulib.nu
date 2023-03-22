#!/usr/bin/env nu

def main [] {
  print -e "commands: [ startvm, tails ]"
}

def "main startvm" [ vmname: string ] {
  ^sudo setfacl -m g:qemu-libvirtd:r-x $env.HOME
  ^virsh -c 'qemu:///system' start $vmname
}

def "main tails" [] {
  # sound=ac97 display=spice/qxl
  let lso = (http get "https://tails.boum.org/install/v2/Tails/amd64/stable/latest.json")
  let ver = ($lso.installations | first | get "version")

  let dest = $"($env.HOME)/.cache/tails/($ver)"
  let f = $"tails-amd64-($ver)"
  if (not ($dest | path exists)) {
    mkdir $dest
    let isoUrl = $"https://tails.boum.org/torrents/files/($f).iso.torrent"
    let imgUrl = $"https://tails.boum.org/torrents/files/($f).img.torrent"
    ^aria2c --seed-time 0 --dir $dest -Z $isoUrl $imgUrl
    ln -sf $"($dest)/($f)-iso/($f).iso" $"($env.HOME)/.cache/tails/tails.iso"
    ln -sf $"($dest)/($f)-img/($f).img" $"($env.HOME)/.cache/tails/tails.img"
  }
}
