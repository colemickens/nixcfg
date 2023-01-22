# woo, lets go

def main [ d: string ] {
  ../main.nu cachedl $"images.($d).installFiles"
  
  let out = $(readlink result)
  sudo rsync -avh --delete $"($out)/boot/" "/tmp/mnt-boot/"
  sudo rsync -avh $"($out)/root/" "/tmp/mnt-root/"

  let toplevel = "$(cat $out/root/toplevel)"
  sudo nix copy $toplevel --no-check-sigs --to /tmp/mnt-root
}
