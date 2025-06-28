{ pkgs, ... }:

let
  # _nvtop = pkgs.nvtop.override { nvidia = false; };
  _nvtop = pkgs.nvtopPackages.amd;
in
{
  config = {
    hardware.graphics.enable = true;

    # hardware.gpu.radeon = {
    #   enable = true;
    #   utils.enable = true;
    # };

    environment.systemPackages = with pkgs; [
      _nvtop
    ];

    # services.lact.enable = true;

    environment.sessionVariables = {
      DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1 = "1";
      # VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    };
  };
}
