#!/usr/bin/env bash

export WLR_RENDERER="vulkan"
export DXVK_HDR=1
export ENABLE_GAMESCOPE_WSI=1

vkdevice="1002:73ef"

gamescope \
  --prefer-vk-device $vkdevice \
  -F fsr \
  --output-width 3840 \
  --output-height 2160 \
  --nested-width 1920 \
  --nested-height 1080 \
  --adaptive-sync \
  --hdr-enabled \
  --hdr-itm-enable \
  --steam \
  -O HDMI-A-1 \
  -- steam -tenfoot -pipewire-dmabuf
