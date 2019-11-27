{ pkgs, lib, ... }:

# TODO: look at `chromium-git` from volth

let
  chromiumOzone = pkgs.chromium-git_80.overrideDerivation (old: {
    src = pkgs.fetchFromGitHub {
      owner = "kennylevinsen";
      repo = "chromium";
      rev = "2e4c2484262d9ae0c3e46bef84903511112ce022";
      sha256 = "0jn8894ikzlg4gybraacm6sykyrm0vj5388dcysppic2bawxw3mn";
    };
    customGnFlags = {
      use_ozone = true;
      use_system_minigbm = true;
      ozone_auto_platforms = false;
      ozone_platform = "wayland";
      ozone_platform_wayland = true;
      ozone_platform_x11 = true;
      ozone_platform_headless = true;
    };
  });
  chromiumOzone_widevine = chromiumOzone.overrideDerivation(old: {
    customGnFlags = old.customGnFlags // { enable_widevine = true; };
  });
in
{
  environment.systemPackages = []
    ++ (with pkgs; [ chromium ])
    ++ lib.optionals (lib.pathExists /etc/nixos/packet) [
      chromiumOzone
      chromiumOzone_widevine
    ];
}
