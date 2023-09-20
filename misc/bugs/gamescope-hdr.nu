#!/usr/bin/env nu

$env.WLR_RENDERER = "vulkan"
$env.DXVK_HDR = 1
$env.ENABLE_GAMESCOPE_WSI = 1 

let vkdevice = "1002:73ef"
let log = $"($env.HOME)/gamescopelogs/(date now | format date '%s')"

(gamescope 
  --prefer-vk-device $vkdevice
  # --fullscreen
  # --adaptive-sync
  # --hdr-enabled
  --steam
  # --disable-color-management
  -- steam 
    -tenfoot
    -pipewire-dmabuf out+err> $log)

# nushell questions:
# - #1 how to do "${@}"
# - #2 how to do out+err| ???
# - #3 how to do tee?? see #2 |& tee /tmp/hdr.log
