{ pkgs, lib, config, inputs, ... }:

{
  config = {
    hardware.gpu.radeon = {
      enable = true;
      utils.enable = true;
    };

    environment.sessionVariables = {
      DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    };
  };
}
