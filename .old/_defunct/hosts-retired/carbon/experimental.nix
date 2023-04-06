{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/ttys.nix
  ];

  config = {
    # sway/raisin: use vulkan? why not?
    environment.sessionVariables = {
      WLR_RENDERER = "vulkan";
      VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    };
    
    services.ttys = {
      unsafe_enable = true;
      vts = {
        tty1 = {
          ttyType = "getty";
          getty.autologinUser = "cole";
        };
        # tty2 (will default to getty, with getty = { similar opts/defaults as getty module })
        tty3 = {
          ttyType = "kmscon";
          kmscon.drm = false;
          kmscon.hwaccel = false;
        };
        tty4 = {
          ttyType = "kmscon";
          kmscon.drm = true;
          kmscon.hwaccel = false;
        };
        tty5 = {
          ttyType = "kmscon";
          kmscon.drm = true;
          kmscon.hwaccel = true;
        };
        # tty6 is, by default, logind's ReservedVT (however, we run the unit for it)
        # TODO: the module should assert that "${config.services.logind.reservedVT}" is not set by the user
      };
    };
  };
}
