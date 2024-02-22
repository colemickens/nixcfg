{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  utils = import ./install-helpers.nix { inherit (pkgs) writeShellScriptBin; };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./configuration-base.nix

    ../../mixins/iwd-networks.nix
  ];

  config = {
    # TODO: remove when not debugging:
    isoImage.squashfsCompression = null;


    ## <tailscale auto-login>
    services.tailscale = {
      enable = true;
      # state = "mem:";
    };
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        echo "trying to connect to tailscale" &>2
        sudo tailscale login --qr
      )
    '';
    services.getty.autologinUser = lib.mkForce "cole";
    ## </tailscale auto-login>

    boot.loader.timeout = lib.mkOverride 10 10;

    ## my custom installer utils
    environment.systemPackages =
      (with utils; [
        cm-nixos-prep
        cm-nixos-mount
        cm-nixos-install
      ])
      ++ (with pkgs; [
        sbctl
        # bcachefs-tools
      ]);
  };
}
