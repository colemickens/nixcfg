{ stdenv, lib, buildPackages, fetchFromGitLab, perl, buildLinux, ... } @ args:

let
  # https://gitlab.collabora.com/hardware-enablement/rockchip-3588/linux/-/tree/rk3588?ref_type=heads
  # 7a5aac740d804bf907bb3781c011a051fdcabd7e
  modDirVersion = "6.5.0-rc1";
  tag = "7a5aac740d804bf907bb3781c011a051fdcabd7e";
  hash = "sha256-GlZiS3l2kW86Ktd0vrAeCIkp7oHhQYv3baTiaBrlAIE=";
  # modDirVersion = "5.10.160";
  # tag = "f96638870c512fd94191e31b744f493af3594f96";
  # hash = "sha256-+FI1Uzy2ROgrPGUNkZ5ZDQRgTMpGmJ/sPE2lXXPJ6bw=";
in
buildLinux (args // {
  version = "${modDirVersion}";
  inherit modDirVersion;

  src = fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "linux";
    rev = tag;
    hash = hash;
  };

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

  # defconfig = "defconfig??";

} // (args.argsOverride or { }))
