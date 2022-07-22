{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  netbootServer = "192.168.1.10";
  hn = config.networking.hostName;

  netbootServerPrefix = "${netbootServer}:/";
  childDevice = {
    rpizero1 = "rpizerotwo1";
    rpizero2 = "rpizerotwo2";
  }.${config.networking.hostName};
in
{
  config = {
    # services.rustpiboot = {
    #   payload = "/nfsfirms/";  
    #   script = ''
    #     ${pkgs.rustpiboot} --payload "/nfsboot/${childDevice}";
    #   '';
    # };
    fileSystems = {
      "/nfsboot/${childDevice}" = lib.mkForce {
        device = "${netbootServerPrefix}nfsboots/${childDevice}";
        fsType = "nfs";
        options = [ "x-systemd.idle-timeout=20s" "nolock" "ro" ];
        neededForBoot = false;
      };
      "/nfsfirms/${childDevice}" = lib.mkForce {
        device = "${netbootServerPrefix}nfsfirms/${childDevice}";
        fsType = "nfs";
        options = [ "x-systemd.idle-timeout=20s" "nolock" "ro" ];
        neededForBoot = false;
      };
    };
  };
}
