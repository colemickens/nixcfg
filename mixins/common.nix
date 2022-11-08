{ config, lib, pkgs, inputs, options, ... }:

let
  cfg = config.nixcfg.common;
  defaultKernel = pkgs.linuxKernel.packages.linux_6_0;
  defaultZfsKernel = pkgs.linuxKernel.packages.linux_6_0;
  _zfsEnableUnstable = true;
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
  hn = config.networking.hostName;
  defaultTimeServers = options.networking.timeServers.default;
  _defaultTimeServers = [
    "0.nixos.pool.ntp.org"
    "1.nixos.pool.ntp.org"
    "2.nixos.pool.ntp.org"
    "3.nixos.pool.ntp.org"
  ];
in
{
  imports = [
    ./nix.nix
    ../profiles/user.nix
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
      useXeepTimeserver = lib.mkOption {
        type = lib.types.bool;
        # default = true; # TODO: this is questionable...
        default = false; # TODO: this is questionable...
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
        supportedFilesystems = lib.optionals (cfg.useZfs) [ "zfs" ];
        initrd.supportedFilesystems = lib.optionals (cfg.useZfs) [ "zfs" ];

        # TODO: consider moving to non-interactive hosts only
        kernelParams = [ "mitigations=off" ];

        loader.grub = {
          pcmemtest.enable = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86) true;
          timeoutStyle = "hidden";
          configurationLimit = 10;
        };
        loader.systemd-boot = {
          configurationLimit = 10;
        };
        loader.timeout = 1;
        kernelPackages = lib.mkIf cfg.defaultKernel (lib.mkDefault (if cfg.useZfs then defaultZfsKernel else defaultKernel));
        zfs.enableUnstable = lib.mkIf (cfg.defaultKernel && cfg.useZfs && _zfsEnableUnstable) true;
        kernel.sysctl = {
          "fs.file-max" = 100000;
          "fs.inotify.max_user_instances" = 256;
          "fs.inotify.max_user_watches" = 99999999;
        };
      };

      # system.disableInstallerTools = true;

      ###################################
      ## NETWORK 
      ###################################
      # - no wifi by default
      #   so add iwd/wireless per-host
      networking.hostId = pkgs.lib.concatStringsSep "" (pkgs.lib.take 8
        (pkgs.lib.stringToCharacters
          (builtins.hashString "sha256" config.networking.hostName)));
      networking.firewall.enable = true;
      networking.useDHCP = lib.mkIf (cfg.defaultNetworking) false;
      networking.useNetworkd = lib.mkIf (cfg.defaultNetworking) true;
      services.resolved.enable = true;

      # TODO: Fuck OVHCloud.
      # networking.extraHosts = let ip = "100.72.11.62"; in ''
      #   ${ip} cleo.cat
      #   ${ip} x.cleo.cat
      #   ${ip} home.x.cleo.cat
      #   ${ip} sd.cleo.cat
      #   ${ip} sdo.cleo.cat
      # '';
      networking.firewall.logRefusedConnections = true;
      networking.timeServers = [ ]
        ++ (if cfg.useXeepTimeserver then [ "192.168.1.10" ] else [ ])
        ++ defaultTimeServers;

      systemd.network = (lib.mkIf (cfg.defaultNetworking) {
        enable = true;

        wait-online.anyInterface = true;
        wait-online.ignoredInterfaces = [ "wlan0" "wlp1s0" "wlp2s0" "tailscale0" "virbr0" ];

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
          routes = [
            { routeConfig = { Gateway = "_dhcp4"; Metric = 1500; }; }
            { routeConfig = { Gateway = "_ipv6ra"; Metric = 1500; }; }
          ];
          dhcpV4Config.Use6RD = "yes";
          dhcpV6Config.PrefixDelegationHint = "::64";
        };
      });

      ###################################
      ## PACKAGES / NIXPKGS CONFIG
      ###################################
      environment.systemPackages = with pkgs;
        [
          coreutils
        ];
      nixpkgs.overlays = [
        inputs.self.overlays.default
      ];

      specialisation = {
        "sysdinit" = {
          inheritParentConfig = true;
          configuration = {
            config = {
              boot.initrd.systemd.enable = true;

              boot.initrd.luks.devices = lib.mkIf
                (builtins.hasAttr "nixos-luksroot" config.boot.initrd.luks.devices)
                {
                  "nixos-luksroot" = {
                    crypttabExtraOpts = [
                      "fido2-device=auto"
                    ];
                  };
                };
            };
          };
        };
      };

      ###################################
      ## SYSTEM
      ###################################
      services.fwupd.enable = true;
      services.timesyncd.enable = true;
      # services.journald.extraConfig = ''
      #   SystemMaxUse=10M
      # '';
      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = lib.mkDefault "America/Los_Angeles";
      services.getty = {
        greetingLine = ''\l  -  (kernel: \r) (label: ${config.system.nixos.label}) (arch: \m)'';
        helpLine = ''
          -... . / --. .- -.-- --..-- / -.. --- / -.-. .-. .. -- .
        '';
      };

      security.please.enable = true;
      security.sudo.wheelNeedsPassword = false;
      users.mutableUsers = false;
      users.users."root".initialHashedPassword = lib.mkForce "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      users.users."root".hashedPassword = config.users.users."root".initialHashedPassword;

      hardware.enableRedistributableFirmware = true;
    });
}

