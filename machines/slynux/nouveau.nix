{ pkgs, ... }:
{
  boot = {
    kernelPatches = [
      {
        name = "nouveau-gr-fix";
        patch = (
          pkgs.fetchpatch {
            url = "https://github.com/karolherbst/linux/commit/0a4d0a9f2ab29b4765ee819753fbbcbc2aa7da97.patch";
            sha256 = "0cqg6yc22aqflzjf5xijy4rc78hxi9bhdnbhm671xm4bksp4ad34";
          }
        );
      }
      {
        name = "nouveau-runpm-fix";
        patch = (
          pkgs.fetchpatch {
            url = "https://github.com/karolherbst/linux/commit/1e6cef9e6c4d17f6d893dae3cd7d442d8574b4b5.patch";
            sha256 = "0x4jw5a15zslny5cyjq0m5jl7qbnlchadighs57n082arf1wc917";
          }
        );
      }
    ];
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ libva-full libvdpau-va-gl vaapiVdpau ];
    };
  };
}
