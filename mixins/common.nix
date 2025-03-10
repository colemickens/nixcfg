{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:

let
  cfg = config.nixcfg.common;
  # _kernelPackages = pkgs.linuxPackages_latest;
  _kernelPackages =
    if cfg.useZfs then
      if cfg.useZfsUnstable then
        pkgs.linuxKernel.packages.linux_6_13
      else
        pkgs.linuxKernel.packages.linux_6_12 # new LTS
    else
      pkgs.linuxKernel.packages.linux_latest;
in
{
  imports = [
    ./nix.nix
    ../profiles/user-cole.nix
  ];

  options = {
    nixcfg.common = {
      defaultKernel = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          ideally, all machines run mainline. this is mostly disabled for mobile-nixos devices
          (also, in most cases linuxPackages could just be overridden directly)
          # TODO: it would be nice if mobile-nixos didn't make me need this...
        '';
      };
      wifiWorkaround = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          whether to restart systemd-udev-trigger on new generation activation
          (use this on wifi-only, non-gui hosts, aka openstick)
        '';
      };
      defaultNoDocs = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      defaultNetworking = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      useZfs = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      useZfsUnstable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      autoHostId = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      hostColor = lib.mkOption {
        type = lib.types.str;
        default = "cyan";
        description = "this is used as a hostname-hint-accent in zellij/waybar/shell prompts";
      };
      skipMitigations = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = ({
    ## DEBLOAT ##############################################################
    documentation = (
      lib.mkIf cfg.defaultNoDocs ({
        enable = false;
        doc.enable = false;
        man.enable = false;
        info.enable = false;
        nixos.enable = false;
      })
    );
    # system.disableInstallerTools = lib.mkDefault true;

    ## BOOT #################################################################
    console.earlySetup = true; # needed for LUKS
    boot = {
      enableContainers = false;
      tmp = {
        useTmpfs = lib.mkDefault false;
        cleanOnBoot = true;
      };

      loader = {
        efi = {
          canTouchEfiVariables = true;
        };
        grub = {
          enable = lib.mkDefault false;
          # memtest86.enable = (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86);
          # timeoutStyle = "hidden"; # dropped from my nixpkgs
          configurationLimit = 10;
        };
        systemd-boot = {
          enable = lib.mkDefault true;
          configurationLimit = 10;
          memtest86.enable = (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86);
          memtest86.sortKey = "z_memtest86";
        };
        timeout = 3;
      };

      initrd.systemd.enable = lib.mkDefault true;
      initrd.supportedFilesystems = ([ "ntfs" ] ++ lib.optionals (cfg.useZfs) [ "zfs" ]);

      zfs.package = lib.mkIf (cfg.useZfs && cfg.useZfsUnstable) pkgs.zfs_unstable;

      kernelPackages = lib.mkIf cfg.defaultKernel _kernelPackages;
      kernelParams = lib.mkIf cfg.skipMitigations [ "mitigations=off" ];
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 99999999;
      };
    };

    ## NETWORK + TIME #######################################################
    networking = {
      hostId = lib.mkIf cfg.autoHostId (
        pkgs.lib.concatStringsSep "" (
          pkgs.lib.take 8 (
            pkgs.lib.stringToCharacters (builtins.hashString "sha256" config.networking.hostName)
          )
        )
      );
      firewall.enable = true;
      useDHCP = lib.mkIf (cfg.defaultNetworking) false;
      # useNetworkd = lib.mkIf (cfg.defaultNetworking) true;

      resolvconf.dnsExtensionMechanism = false;

      firewall.logRefusedConnections = false;
    };
    services.resolved = {
      enable = true;
      extraConfig = ''
        [Resolve]
        DNSSEC=false
      '';
    };
    services.timesyncd.enable = true;
    time.timeZone = lib.mkDefault "America/Los_Angeles";

    # TODO/WORKAROUND: https://github.com/NixOS/nixpkgs/issues/195777
    system.activationScripts = lib.mkIf cfg.wifiWorkaround {
      workaroundWifi = {
        # sometimes, I wonder if Linux is worth it:
        # - uptime is unparseable garbage
        # -/proc/uptime is of course floats that are space separated
        text = ''
          (
          set -x 
          uptime_ms="$(cat /proc/uptime | cut -d ' ' -f 1)"
          uptime_ms="$(echo $uptime_ms | cut -d '.' -f 1)"
          if [[ ''${uptime_ms} -gt ${toString (60 * 2)} ]]; then 
            echo "workaround_wifi_issue: trigger"
            ${pkgs.systemd}/bin/systemctl restart systemd-udev-trigger
          else
            echo "workaround_wifi_issue: skip"
          fi
          )
        '';
        deps = [ ];
      };
    };

    systemd.network = (
      lib.mkIf (cfg.defaultNetworking) {
        enable = true;

        wait-online = {
          enable = false;
          anyInterface = true;
          extraArgs = [ "--ipv4" ];
        };

        # leave the kernel dummy devies unmanagaed
        networks."10-dummy" = {
          matchConfig.Name = "dummy*";
          networkConfig = { };
          # linkConfig.ActivationPolicy = "always-down";
          linkConfig.Unmanaged = "yes";
        };

        networks."20-tailscale-ignore" = {
          matchConfig.Name = "tailscale*";
          linkConfig = {
            Unmanaged = "yes";
            RequiredForOnline = false;
          };
        };

        networks."30-network-defaults-wired" = {
          # matchConfig.Name = "en* | eth* | usb*";
          matchConfig.Type = "ether";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
            # DHCPv6PrefixDelegation = "yes"; # moved to its own full section
            IPv4Forwarding = "yes";
            IPv6Forwarding = "yes";
            # IPMasquerade = "both";
          };
          # dhcpV4Config.ClientIdentifier = "mac";
          dhcpV4Config.Use6RD = "yes";
          dhcpV4Config.RouteMetric = 512;
          # dhcpV4Config.UseDNS = false;
          dhcpV4Config.DUIDType = "link-layer";
          dhcpV6Config.RouteMetric = 512;
          dhcpV6Config.PrefixDelegationHint = "::64";
          # dhcpV6Config.UseDNS = false;
          dhcpV6Config.DUIDType = "link-layer";
        };
        networks."30-network-defaults-wireless" = {
          # matchConfig.Name = "wl*";
          matchConfig.Type = "wlan";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
            # DHCPv6PrefixDelegation = "yes";
            IPv4Forwarding = "yes";
            IPv6Forwarding = "yes";
            # IPMasquerade = "both";
          };
          # dhcpV4Config.ClientIdentifier = "mac";
          dhcpV4Config.RouteMetric = 1500;
          # dhcpV4Config.UseDNS = false;
          dhcpV4Config.DUIDType = "link-layer";
          dhcpV6Config.RouteMetric = 1500;
          # dhcpV6Config.UseDNS = false;
          dhcpV6Config.DUIDType = "link-layer";
          # routes = [
          #   { routeConfig = { Gateway = "_dhcp4"; Metric = 1500; }; }
          #   { routeConfig = { Gateway = "_ipv6ra"; Metric = 1500; }; }
          # ];
          dhcpV4Config.Use6RD = "yes";
          dhcpV6Config.PrefixDelegationHint = "::64";
        };
      }
    );

    security = {
      sudo.enable = true;
      sudo.wheelNeedsPassword = false;
    };

    users = {
      mutableUsers = false;
      users."root".initialHashedPassword =
        lib.mkForce "$6$Qxw65IlG0QZmI./Q$GkV4Ql3jIxWr2yfl.kHoCaEgF4E585l1foG0wdHAwAfy2GbdtalCQPc3gNVUcQ9Ea21kaYqM9GNujL8G.EqCM0";
      users."root".hashedPassword = config.users.users."root".initialHashedPassword;
    };

    ## MISC HARDWARE RELATED ################################################
    services.fwupd.enable = true;
    services.udisks2.enable = true;
    services.zfs.trim.enable = cfg.useZfs;
    services.zfs.autoScrub.enable = cfg.useZfs;
    hardware.enableRedistributableFirmware = true;
    hardware.usb-modeswitch.enable = true; # dual role usb/cdrom stick thing
    hardware.cpu.amd.updateMicrocode = (pkgs.stdenv.hostPlatform.system == "x86_64-linux");
    hardware.cpu.intel.updateMicrocode = (pkgs.stdenv.hostPlatform.system == "x86_64-linux");

    environment = {
      systemPackages = with pkgs; [ coreutils ];
    };

    ## SILLY CUSTOMIZATION ##################################################
    services.getty = {
      greetingLine = "\\l  -  (kernel: \\r) (label: ${config.system.nixos.label}) (system: \\m)";
      helpLine = ''
        -... . / --. .- -.-- --..-- / -.. --- / -.-. .-. .. -- .
      '';
    };
  });
}
