{ fetchpatch }:

let
in
{
  trackpadPatchV3 = {
    name = "apple-magic-trackpad2-driver";
    patch = fetchpatch {
      name = "trackpad.patch";
      url = "https://lkml.org/lkml/diff/2018/9/21/38/1";
      sha256 = "018wyjvw4wz79by38b1r6bkbl34p6686r66hg7g7vc0v24jkcafn";
    };
  };
  trackpadPatchV4 = {
    name = "apple-magic-trackpad2-driver";
    patch = fetchpatch {
      name = "trackpad.patch";
      url = "https://lkml.org/lkml/diff/2018/10/3/111/1";
      sha256 = "10f555falis1n8x7y6sfp0v2la1nrfyry82bwmn7bpjni66jb6gf";
    };
  };
}
