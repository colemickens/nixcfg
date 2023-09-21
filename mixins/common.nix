{ config, lib, pkgs, inputs, options, ... }:

let
  cfg = config.nixcfg.common;
  _kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  _zfsUnstable = true;
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
      kernelPatchHDR = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          patch the kernel with amd-hdr patches
          used to enable the patch but disable it in a specialisation
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
      addLegacyboot = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = ({
    ## DEBLOAT ##############################################################
    documentation = (lib.mkIf cfg.defaultNoDocs ({
      enable = false;
      doc.enable = false;
      man.enable = false;
      info.enable = false;
      nixos.enable = false;
    }));
    # system.disableInstallerTools = lib.mkDefault true;

    ## BOOT #################################################################
    console.earlySetup = true; # needed for LUKS
    boot = {
      enableContainers = false;
      tmp.useTmpfs = lib.mkDefault false;
      tmp.cleanOnBoot = true;
      zfs.enableUnstable = (cfg.useZfs && _zfsUnstable);

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
          # memtest86.enable = (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86);
          memtest86.entryFilename = "z-memtest86.conf";
        };
        timeout = 3;
      };

      initrd.systemd.enable = lib.mkDefault true;
      initrd.supportedFilesystems = (
        [ "ntfs" ] ++
        lib.optionals (cfg.useZfs) [ "zfs" ]
      );

      kernelPackages = lib.mkIf cfg.defaultKernel _kernelPackages;
      kernelParams = lib.mkIf cfg.skipMitigations [ "mitigations=off" ];
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 99999999;
      };
    };

    # default boot kernel is patched, see the "no-amd-hdr" specialisation
    nixcfg.common.kernelPatchHDR = true;

    ## LEGACYBOOT - we use stage-1/systemd so have a fallback ###############
    specialisation = {
      "legacyboot" = lib.mkIf (config.boot.initrd.systemd.enable && config.nixcfg.common.addLegacyboot) {
        inheritParentConfig = true;
        configuration = {
          boot.initrd.systemd.enable = lib.mkForce false;
          boot.initrd.luks.devices."nixos-luksroot".fallbackToPassword = true;
        };
      };
      "no-amd-hdr" = {
        inheritParentConfig = true;
        configuration = {
          nixcfg.common.kernelPatchHDR = lib.mkForce false;
        };
      };
    };

    boot.kernelPatches = lib.mkIf (cfg.kernelPatchHDR) [
      {
        name = "amd-hdr-patch";
        patch = (pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/CachyOS/kernel-patches/d792451352838e29b6b0e4a297e897bf1bb975fe/6.4/0005-HDR.patch";
          hash = "sha256-fGbb3NCyuryXDDtD14GDhc4AK/Ho3I0M1tLOkgJeRdQ=";
        });
      }
    ];

    ## NETWORK + TIME #######################################################
    networking = {
      hostId = lib.mkIf cfg.autoHostId (pkgs.lib.concatStringsSep "" (pkgs.lib.take 8
        (pkgs.lib.stringToCharacters
          (builtins.hashString "sha256" config.networking.hostName))));
      firewall.enable = true;
      useDHCP = lib.mkIf (cfg.defaultNetworking) false;
      useNetworkd = lib.mkIf (cfg.defaultNetworking) true;

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
    system.activationScripts = {
      workaroundWifi = {
        # sometimes, I wonder if Linux is worth it:
        # - uptime is unparseable garbage
        # -/proc/uptime is of course floats that are space separated
        text = ''
          (
          set -x 
          uptime_ms="$(cat /proc/uptime | cut -d ' ' -f 1)"
          uptime_ms="$(echo $uptime_ms | cut -d '.' -f 1)"
          if [[ ''${uptime_ms} -gt ${ toString (60 * 5) } ]]; then 
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

    systemd.network = (lib.mkIf (cfg.defaultNetworking) {
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
          IPForward = "yes";
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
          IPForward = "yes";
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
    });

    security = {
      sudo.enable = true;
      sudo.wheelNeedsPassword = false;
    };

    users = {
      mutableUsers = false;
      users."root".initialHashedPassword = lib.mkForce "$6$Qxw65IlG0QZmI./Q$GkV4Ql3jIxWr2yfl.kHoCaEgF4E585l1foG0wdHAwAfy2GbdtalCQPc3gNVUcQ9Ea21kaYqM9GNujL8G.EqCM0";
      users."root".hashedPassword = config.users.users."root".initialHashedPassword;
    };

    ## MISC HARDWARE RELATED ################################################
    services.fwupd.enable = true;
    services.udisks2.enable = true;
    services.zfs.trim.enable = cfg.useZfs;
    services.zfs.autoScrub.enable = cfg.useZfs;
    hardware.enableRedistributableFirmware = true;
    hardware.usb-modeswitch.enable = true; # dual role usb/cdrom stick thing
    hardware.cpu.amd.updateMicrocode = (pkgs.hostPlatform.system == "x86_64-linux");
    hardware.cpu.intel.updateMicrocode = (pkgs.hostPlatform.system == "x86_64-linux");

    environment = {
      systemPackages = with pkgs; [ coreutils ];
    };

    ## SILLY CUSTOMIZATION ##################################################
    services.getty = {
      greetingLine = ''\l  -  (kernel: \r) (label: ${config.system.nixos.label}) (system: \m)'';
      helpLine = ''
        -... . / --. .- -.-- --..-- / -.. --- / -.-. .-. .. -- .
      '';
    };
  });
}

