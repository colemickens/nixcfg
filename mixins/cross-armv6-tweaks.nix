{ config, pkgs, lib, ... }: 

# https://github.com/samueldr/cross-system/blob/7a8f243f/configuration.nix

{
  config = {
    nixpkgs.overlays = [(self: super: {
      # SO FAR, haven't needed these:
      #
      # # Does not cross-compile...
      # alsa-firmware = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";

      # # A "regression" in nixpkgs, where python3 pycryptodome does not cross-compile.
      # crda = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";

      # # Regression caused by including a new package in the closure
      # # Added in f1922cdbdc608b1f1f85a1d80310b54e89d0e9f3
      # smartmontools = super.smartmontools.overrideAttrs(old: {
      #   configureFlags = [];
      # });

      # # spidermonkey, needed for polkit, needed for wpa_supplicant,
      # # does not cross-compile.
      # wpa_supplicant = self.pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";
    })];
  };
}
