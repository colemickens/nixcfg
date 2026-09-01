# A MicroVM running a stripped-down NixOS whose only job is to run a second
# Tailscale node.
#
# Host networking is deliberately left alone: microvm.nix creates and tears
# down the TAP itself in microvm-tap-interfaces@raisin-ts.service, and nothing
# here touches raisin's own networking from mixins/common.nix.
{
  config,
  lib,
  inputs,
  ...
}:

let
  hostCfg = config;
  vmName = "work-ts";
  vmLink = "vm-${vmName}";
  guestMac = "02:00:00:52:41:01";
in
{
  imports = [
    inputs.microvm.nixosModules.host
  ];

  config = {
    microvm.vms."${vmName}" = {
      # Built and switched as part of raisin's own nixos-rebuild.
      autostart = true;

      config = {
        microvm = {
          hypervisor = "qemu";
          vcpu = 1;
          mem = 512;

          # Created and torn down by microvm-tap-interfaces@raisin-ts.service.
          interfaces = [
            {
              type = "tap";
              id = vmLink;
              mac = guestMac;
            }
          ];
          shares = [
            {
              proto = "virtiofs";
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
          ];
          volumes = [
            {
              image = "/var/lib/microvms/${vmName}/tailscale-state.img";
              mountPoint = "/var/lib/tailscale";
              size = 128;
            }
          ];
        };

        networking.hostName = vmName;

        # The entire point of this VM.
        services.tailscale = {
          enable = true;
          useRoutingFeatures = "both";
        };
        networking.firewall.trustedInterfaces = [ "tailscale0" ];

        # For `tailscale up` and general debugging.
        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
        };
        users.users."root".openssh.authorizedKeys.keys =
          hostCfg.users.users."cole".openssh.authorizedKeys.keys;

        # Keep it small: no docs, no default package set, no firmware.
        documentation.enable = false;
        documentation.doc.enable = false;
        documentation.info.enable = false;
        documentation.man.enable = false;
        documentation.nixos.enable = false;
        environment.defaultPackages = lib.mkForce [ ];
        programs.command-not-found.enable = false;
        hardware.enableRedistributableFirmware = lib.mkForce false;
        security.sudo.enable = false;
        xdg.autostart.enable = false;
        xdg.icons.enable = false;
        xdg.mime.enable = false;
        xdg.sounds.enable = false;

        system.stateVersion = "26.05";
      };
    };
  };
}
