{ pkgs, ... }:

# TODO: look at `chromium-git` from volth

let
  chromiumCustom = pkgs.chromium.override {
    channel = "dev";
    enableWideVine = true;
  };
in
{
  environment.systemPackages = [
    pkgs.chromium
    #chromiumCustom
  ];
}
