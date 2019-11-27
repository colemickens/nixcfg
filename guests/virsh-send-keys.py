#!/usr/bin/env python3

import subprocess
import time

# (note, this is generalized to not having the tpm available
# which means certain other things won't work with this guest too
# like Windows Hello PIN etc)

# fortunately bitlocker recovery keys only need these
linux_keycodes = {
  "KEY_1": 2,
  "KEY_2": 3,
  "KEY_3": 4,
  "KEY_4": 5,
  "KEY_5": 6,
  "KEY_6": 7,
  "KEY_7": 8,
  "KEY_8": 9,
  "KEY_9": 10,
  "KEY_0": 11,
}

def main():
  bitlocker_key=subprocess.run(["gopass", "show", "misc/BITLOCKER"], capture_output=True)
  bitlocker_key=bitlocker_key.stdout
  print(bitlocker_key)
  
  bitlocker_key = next(line for line in 
    bitlocker_key.decode('utf-8').split('\n')
    if line.startswith("xeepwin_recovery"))

  bitlocker_key = bitlocker_key.split(":")[1].strip()

  guest = "generic"

  print(bitlocker_key)

  for key in bitlocker_key:
    keyname="KEY_"+key
    if keyname not in linux_keycodes: continue

    keycode = linux_keycodes["KEY_"+key]
    args=["sudo", "virsh", "send-key", guest, "%d" % keycode]
    print(args)
    subprocess.run(args, capture_output=True)
    time.sleep(.05)

  subprocess.run(["sudo", "virsh", "send-key", guest, "28" ])

if __name__ == '__main__':
  main()
