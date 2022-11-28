{ stdenv, lib, buildPackages, fetchFromGitHub, perl, buildLinux, ... } @ args:

let
  modDirVersion = "5.8.1-xboxdev";
  tag = "cc89bd62acde4130b24854711db18c6513678484";
in
buildLinux (args // {
  version = "${modDirVersion}";
  inherit modDirVersion;

  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "linux";
    rev = tag;
    hash = "sha256-nfAbnPiYdVVvx0WSWcZWwKfqqLMWelydJj2FLEhjIzU=";
  };

  ignoreConfigErrors = true;

  # structuredExtraConfig = with lib.kernel; {
  #   # Not needed, and implementation iffy / does not build / used for testing
  #   MALI_KUTF = no;
  #   MALI_IRQ_LATENCY = no;
  #   # Build fails, "legacy/webcam.c" we don't need no legacy stuff.
  #   USB_G_WEBCAM = no;
  #   # Poor quality drivers, bad implementation, not needed
  #   WL_ROCKCHIP = no; # A lot of badness
  #   RK628_EFUSE = no; # Not needed, used to "dump specified values"
  #   # Used on other rockchip platforms
  #   ROCKCHIP_DVBM = no;
  #   RK_FLASH = no;
  #   PCIEASPM_EXT = no;
  #   ROCKCHIP_IOMUX = no;
  #   RSI_91X = no;
  #   RSI_SDIO = no;
  #   RSI_USB = no;

  #   # Driver conflicts with the mainline ones
  #   # > error: the following would cause module name conflict:
  #   COMPASS_AK8975 = no;
  #   LS_CM3232 = no;
  #   GS_DMT10 = no;
  #   GS_KXTJ9 = no;
  #   GS_MC3230 = no;
  #   GS_MMA7660 = no;
  #   GS_MMA8452 = no;

  #   # ALSO BROKEN:
  #   RK630_PHY = no;
  #   REGULATOR_WL2868C = no;
  #   DRM_RCAR_DW_HDMI = no;
  #   DEBUG_INFO_BTF = lib.mkForce no;
  #   DEBUG_INFO_BTF_MODULES = lib.mkForce no;
    
  #   # This is not a good console...
  #   # FIQ_DEBUGGER = no;
  #   # TODO: Fix 8250 console not binding as a console

  #   # from vendor config
  #   #DRM_DP = no; # ????? does not build with it disabled ffs
  #   DRM_DEBUG_SELFTEST = no;

  #   # Ugh...
  #   ROCKCHIP_DEBUG = no;
  #   RK_CONSOLE_THREAD = no;
  # };

  kernelPatches = [
    # { patch = ./linux-rock5-patch.patch; }
  ] ++ (with buildPackages.kernelPatches; [
    bridge_stp_helper
    request_key_helper
  ]);

  defconfig = "xbox_defconfig";

} // (args.argsOverride or { }))
