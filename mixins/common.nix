{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.nixcfg.common;
  defaultKernel = pkgs.linuxPackages_latest;
  _defaultKernel = pkgs.linuxKernel.packagesFor
    (pkgs.linuxPackages_latest.kernel.override {
      structuredExtraConfig = {
        FB = lib.mkForce lib.kernel.no;
        FB_SIMPLE = lib.mkForce lib.kernel.option lib.kernel.no;
        FB_EFI = lib.mkForce lib.kernel.option lib.kernel.no;

        AGP = lib.mkForce lib.kernel.no;
        HAS_IOMEM = lib.mkForce lib.kernel.yes;
        HAS_DMA = lib.mkForce lib.kernel.yes;
        MMU = lib.mkForce lib.kernel.yes;
        DRM = lib.mkForce lib.kernel.yes;
        DRM_SIMPLEDRM = lib.mkForce lib.kernel.yes;
        SYSFB_SIMPLEFB = lib.mkForce lib.kernel.yes;
      } // (lib.genAttrs
        (
          [ "DRM_VMWGFX_FBCON" "LOGO" ]
            ++ [ "FRAMEBUFFER_CONSOLE" "FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER" "FRAMEBUFFER_CONSOLE_ROTATION" ]
            ++ [ "FB_3DFX_ACCEL" "FB_ATY_CT" "FB_ATY_GX" "FB_EFI" "FB_NVIDIA_I2C" "FB_RIVA_I2C" ]
            ++ [ "FB_SAVAGE_ACCEL" "FB_SAVAGE_I2C" "FB_SIMPLE" "FB_SIS_300" "FB_SIS_315" "FB_VESA" ]
        )
        (x: lib.mkForce (lib.kernel.option lib.kernel.no))
      );
    });
  hn = config.networking.hostName;
in
{
  imports = [
    ./nix.nix
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
      hostColor = lib.mkOption {
        type = lib.types.str;
        default = "grey";
        description = "this is used as a hostname-hint-accent in zellij/waybar/shell prompts";
      };
      defaultTheme = lib.mkOption {
        type = lib.types.str;
        default = "XXX";
        description = ''
          This is the name of an iterm2 theme.
          Used for zellij, helix, sway, mako, etc.
        '';
      };
    };
  };

  config =
    ({
      ###################################
      ## DEBLOAT
      ###################################
      documentation = (lib.mkIf cfg.defaultNoDocs ({
        enable = false;
        doc.enable = false;
        man.enable = true;
        info.enable = false;
        nixos.enable = false;
      }));

      ###################################
      ## BOOT
      ###################################
      console.earlySetup = true; # needed for LUKS
      boot = {
        tmpOnTmpfs = lib.mkDefault false;
        cleanTmpDir = true;
        supportedFilesystems = [ "zfs" ];
        initrd.supportedFilesystems = [ "zfs" ];

        # TODO: consider moving to non-interactive hosts only
        kernelParams = [ "mitigations=off" ];

        loader.grub = {
          pcmemtest.enable = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86) true;
          timeoutStyle = "hidden";
          timeout = 1;
        };
        kernelPackages = lib.mkIf cfg.defaultKernel defaultKernel;
        kernel.sysctl = {
          "fs.file-max" = 100000;
          "fs.inotify.max_user_instances" = 256;
          "fs.inotify.max_user_watches" = 500000;
        };
      };

      ###################################
      ## NETWORK 
      ###################################
      # - no wifi by default
      #   so add iwd/wireless per-host
      networking.firewall.enable = true;
      networking.useDHCP = false;
      networking.hostId = pkgs.lib.concatStringsSep "" (pkgs.lib.take 8
        (pkgs.lib.stringToCharacters
          (builtins.hashString "sha256" config.networking.hostName)));
      networking.useNetworkd = true;
      services.resolved.enable = true;
      systemd.network =
        let
          bridge = "wanbr0";
          bridge2 = "vmbr0";
          bond = "wanbond0";
        in
        {
          enable = true;

          # leave the kernel dummy devies unmanagaed
          networks."10-dummy" = {
            matchConfig.Name = "dummy*";
            networkConfig = { };
            # linkConfig.ActivationPolicy = "always-down";
            linkConfig.Unmanaged = "yes";
          };

          # setup a bond
          netdevs."09-netdev-${bond}" = {
            netdevConfig.Name = bond;
            netdevConfig.Kind = "bond";
            bondConfig = {
              Mode = "active-backup";
              PrimaryReselectPolicy = "always";
              MIIMonitorSec = "1s";
            };
          };
          # setup a bridge to the bond to allow bridged devices a way out
          netdevs."10-netdev-${bridge}" = {
            netdevConfig.Name = bridge;
            netdevConfig.Kind = "bridge";
          };
          netdevs."10-netdev-${bridge2}" = {
            netdevConfig.Name = bridge2;
            netdevConfig.Kind = "bridge";
          };
          # bind them
          networks."25-bind-${bridge}-${bond}" = {
            matchConfig.Name = bond;
            networkConfig = {
              Bridge = bridge;
              # DHCP = "yes";
              # IPv6AcceptRA = true;
            };
          };

          # actually dhcp on our bond out to the wan
          # networks."25-network-${bond}" = {
          #   matchConfig.Name = bond;
          #   linkConfig.RequiredForOnline = "no";
          #   # linkConfig.ActivationPolicy = "bound";
          # };
          networks."20-network-${bridge}" = {
            matchConfig.Name = bridge;
            networkConfig = {
              DHCP = "yes";
              IPv6AcceptRA = true;
              DHCPv6PrefixDelegation = "yes";
              IPForward = "yes";
              IPMasquerade = "both";
            };
            # dhcpV4Config.ClientIdentifier = "mac";
            dhcpV4Config.Use6RD = "yes";
            dhcpV6Config.PrefixDelegationHint = "::64";
            linkConfig.RequiredForOnline = "yes";
          };
          networks."20-network-${bridge2}" = {
            matchConfig.Name = bridge2;
            networkConfig = {
              DHCP = "no";
              Address="10.0.200.0/24";
              DHCPServer = "yes";
              IPForward = "ipv4";
              IPMasquerade = "ipv4";
            };
            dhcpServerConfig = {
              # ServerAddress = "10.0.200.0/24";
              EmitDNS = "yes";
              DNS = "1.1.1.1";
              PoolSize=20;
              PoolOffset=0;
            };
            linkConfig.RequiredForOnline = "no";
          };
  
          # TODO: catch all - bind all the rndis_host/cdc_ethers?
              
          # catch all defaults
          # - remaining USB devices are probably usb adapters
          #   so put them in our WAN bond
          networks."90-bond-eth" = {
            matchConfig.Name = "en* | eth*";
            networkConfig = {
              Bond = bond;
              PrimarySlave = "yes";
            };
            linkConfig.RequiredForOnline = "no";
            # linkConfig.ActivationPolicy = "...";
          };
          networks."91-bond-the-rest" = {
            matchConfig.Name = "usb* | wl*";
            networkConfig = {
              Bond = bond;
            };
            linkConfig.RequiredForOnline = "no";
            # linkConfig.ActivationPolicy = "bound";
          };
        };

      ###################################
      ## PACKAGES / NIXPKGS CONFIG
      ###################################
      environment.systemPackages = with pkgs;
        [
          coreutils
        ];
      nixpkgs.overlays = [
        inputs.self.overlay
      ];

      ###################################
      ## SYSTEM
      ###################################
      services.fwupd.enable = true;
      services.timesyncd.enable = true;
      services.journald.extraConfig = ''
        SystemMaxUse=10M
      '';
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = lib.mkDefault "America/Los_Angeles";
      services.getty = {
        greetingLine = ''\l  -  (kernel: \r) (label: ${config.system.nixos.label}) (arch: \m)'';
        helpLine = ''
          -... . / --. .- -.-- --..-- / -.. --- / -.-. .-. .. -- .
        '';
      };

      security.sudo.wheelNeedsPassword = false;
      users.mutableUsers = false;
      users.users."root".initialHashedPassword = lib.mkForce "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      users.users."root".hashedPassword = config.users.users."root".initialHashedPassword;

      hardware.enableRedistributableFirmware = true;
    });
}

