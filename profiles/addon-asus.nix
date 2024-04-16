{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = {
    programs = {
      rog-control-center.enable = true;
    };
    services = {
      asusd = {
        enable = true;
        enableUserService = true;
      };
      supergfxd = {
        enable = true;
        settings = {
          always_reboot = false;
          no_logind = true;
          mode = "Integrated";
          # mode = "Hybrid";
          vfio_enable = false;
          vfio_save = false;
          logout_timeout_s = 180;
          hotplug_type = "None";
        };
      };
    };
  };
}
