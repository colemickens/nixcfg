{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ./bootstrap.nix
    ../../mixins/pipewire.nix

    # ../../profiles/gui-gnomemobile.nix
    ../../profiles/gui-phosh.nix

    # in bootstrap
    # (import "${inputs.mobile-nixos-sdm845}/lib/configuration.nix" {
    #   device = "google-blueline";
    # })
  ];

  config = {
    environment.systemPackages = with pkgs; [
      bottom
    ];
  };
}
