{ config, lib, pkgs, inputs, options, ... }:

let
  cfg = config.nixcfg.common;
  _kernelPackages = pkgs.linuxKernel.packages.linux_6_2;
  _zfsUnstable = true;

  # _defaultKernel = pkgs.linuxKernel.packagesFor
  #   (pkgs.linuxPackages_latest.kernel.override {
  #     structuredExtraConfig = {
  #       FB = lib.mkForce lib.kernel.no;
  #       FB_SIMPLE = lib.mkForce lib.kernel.option lib.kernel.no;
  #       FB_EFI = lib.mkForce lib.kernel.option lib.kernel.no;

  #       AGP = lib.mkForce lib.kernel.no;
  #       HAS_IOMEM = lib.mkForce lib.kernel.yes;
  #       HAS_DMA = lib.mkForce lib.kernel.yes;
  #       MMU = lib.mkForce lib.kernel.yes;
  #       DRM = lib.mkForce lib.kernel.yes;
  #       DRM_SIMPLEDRM = lib.mkForce lib.kernel.yes;
  #       SYSFB_SIMPLEFB = lib.mkForce lib.kernel.yes;
  #     } // (lib.genAttrs
  #       (
  #         [ "DRM_VMWGFX_FBCON" "LOGO" ]
  #           ++ [ "FRAMEBUFFER_CONSOLE" "FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER" "FRAMEBUFFER_CONSOLE_ROTATION" ]
  #           ++ [ "FB_3DFX_ACCEL" "FB_ATY_CT" "FB_ATY_GX" "FB_EFI" "FB_NVIDIA_I2C" "FB_RIVA_I2C" ]
  #           ++ [ "FB_SAVAGE_ACCEL" "FB_SAVAGE_I2C" "FB_SIMPLE" "FB_SIS_300" "FB_SIS_315" "FB_VESA" ]
  #       )
  #       (x: lib.mkForce (lib.kernel.option lib.kernel.no))
  #     );
  #   });
in
{
  imports = [
    ./nix.nix
    ../profiles/user-cole.nix
    ../profiles/user-hole.nix
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
      hostColor = lib.mkOption {
        type = lib.types.str;
        default = "grey";
        description = "this is used as a hostname-hint-accent in zellij/waybar/shell prompts";
      };
      skipMitigations = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config =
    ({
      ## DEBLOAT ##############################################################
      documentation = (lib.mkIf cfg.defaultNoDocs ({
        enable = false;
        doc.enable = false;
        man.enable = false;
        info.enable = false;
        nixos.enable = false;
      }));
      system.disableInstallerTools = true;

      ## BOOT #################################################################
      console.earlySetup = true; # needed for LUKS
      boot = {
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
            timeoutStyle = "hidden";
            configurationLimit = 10;
          };
          systemd-boot = {
            enable = lib.mkDefault true;
            configurationLimit = 20;
            # memtest86.enable = (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86);
            memtest86.entryFilename = "z-memtest86.conf";
          };
          timeout = 3;
        };

        initrd.systemd.enable = true;
        initrd.supportedFilesystems = lib.optionals (cfg.useZfs) [ "zfs" ];

        kernelPackages = lib.mkIf cfg.defaultKernel _kernelPackages;
        kernelParams = lib.mkIf cfg.skipMitigations [ "mitigations=off" ];
        kernel.sysctl = {
          "fs.file-max" = 100000;
          "fs.inotify.max_user_instances" = 256;
          "fs.inotify.max_user_watches" = 99999999;
        };
      };

      ## LEGACYBOOT - we use stage-1/systemd so have a fallback ###############
      specialisation."legacyboot" = lib.mkIf (config.boot.initrd.systemd.enable) {
        inheritParentConfig = true;
        configuration = {
          boot.initrd.systemd.enable = lib.mkForce false;
          boot.initrd.luks.devices."nixos-luksroot".fallbackToPassword = true;
        };
      };


      ## NETWORK + TIME #######################################################
      networking = {
        hostId = pkgs.lib.concatStringsSep "" (pkgs.lib.take 8
          (pkgs.lib.stringToCharacters
            (builtins.hashString "sha256" config.networking.hostName)));
        firewall.enable = true;
        useDHCP = lib.mkIf (cfg.defaultNetworking) false;
        useNetworkd = lib.mkIf (cfg.defaultNetworking) true;

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

      systemd.network = (lib.mkIf (cfg.defaultNetworking) {
        enable = true;

        wait-online.anyInterface = true;

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
          matchConfig.Name = "en* | eth* | usb*";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
            DHCPv6PrefixDelegation = "yes";
            IPForward = "yes";
            # IPMasquerade = "both";
          };
          # dhcpV4Config.ClientIdentifier = "mac";
          dhcpV4Config.Use6RD = "yes";
          dhcpV4Config.RouteMetric = 512;
          dhcpV6Config.RouteMetric = 512;
          dhcpV6Config.PrefixDelegationHint = "::64";
        };
        networks."30-network-defaults-wireless" = {
          matchConfig.Name = "wl*";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
            DHCPv6PrefixDelegation = "yes";
            IPForward = "yes";
            # IPMasquerade = "both";
          };
          # dhcpV4Config.ClientIdentifier = "mac";
          dhcpV4Config.RouteMetric = 1500;
          dhcpV6Config.RouteMetric = 1500;
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

        please.enable = true;
        please.wheelNeedsPassword = false;
      };

      users = {
        mutableUsers = false;
        users."root".initialHashedPassword = lib.mkForce "$6$Qxw65IlG0QZmI./Q$GkV4Ql3jIxWr2yfl.kHoCaEgF4E585l1foG0wdHAwAfy2GbdtalCQPc3gNVUcQ9Ea21kaYqM9GNujL8G.EqCM0";
        users."root".hashedPassword = config.users.users."root".initialHashedPassword;
      };

      ## MISC HARDWARE RELATED ################################################
      services.fwupd.enable = true;
      services.udisks2.enable = true;
      hardware.enableRedistributableFirmware = true;
      hardware.usbWwan.enable = true; # dual role usb/cdrom stick thing
      hardware.cpu.amd.updateMicrocode = (pkgs.hostPlatform.system == "x86_64-linux");
      hardware.cpu.intel.updateMicrocode = (pkgs.hostPlatform.system == "x86_64-linux");

      environment = {
        systemPackages = with pkgs; [ coreutils ];
        etc."flake.lock" = {
          source = ../flake.lock;
        };
      };

      ## SILLY CUSTOMIZATION ##################################################
      services.getty = {
        greetingLine = ''\l  -  (kernel: \r) (label: ${config.system.nixos.label}) (arch: \m)'';
        helpLine = ''
          -... . / --. .- -.-- --..-- / -.. --- / -.-. .-. .. -- .
        '';
      };
    });
}

