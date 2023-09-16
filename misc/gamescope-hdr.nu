#!/usr/bin/env nu

$env.WLR_RENDERER = "vulkan"
$env.DXVK_HDR = 1
$env.ENABLE_GAMESCOPE_WSI = 1 

(gamescope 
  --fullscreen
  --adaptive-sync
  --hdr-enabled
  --steam
  --disable-color-management
  -- steam out+err> /tmp/hdr.log)

# nushell questions:
# - #1 how to do "${@}"
# - #2 how to do out+err| ???
# - #3 how to do tee?? see #2 |& tee /tmp/hdr.log
