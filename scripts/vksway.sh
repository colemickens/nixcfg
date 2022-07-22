#!/usr/bin/env bash

export WLR_RENDERER=vulkan

if [[ "${1-""}" == "nvidia" ]]; then
  export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json"
elif [[ "${1-""}" == "nvidia" ]]; then
  export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
fi

sway -d &>"${HOME}/vksway.log"
