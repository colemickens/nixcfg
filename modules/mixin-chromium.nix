{ pkgs, lib, ... }:

# TODO: look at `chromium-git` from volth

let
  chromiumPkg =
    if builtins.pathExists /tmp/nochromium
    then pkgs.chromium
    #else pkgs.chromium-git-ozone;
    else pkgs.chromium-git-ozone;
in
{
  environment.systemPackages = [ chromiumPkg ];
}
