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

    ../../mixins/iwd-networks.nix

    ../../profiles/core.nix
  ];

  config = {
    ## <tailscale auto-login>
    services.tailscale = {
      enable = true;
      inMemoryState = true;
    };
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        echo "trying to connect to tailscale" &>2
        sudo tailscale login --qr
      )
    '';
    ## </tailscale auto-login>

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

    nixcfg.common.skipMitigations = true;
    nixcfg.common.defaultKernel = true;
    nixcfg.common.addLegacyboot = false;

    system.stateVersion = "23.11";

    services.getty.autologinUser = lib.mkForce "cole";

    boot.swraid.enable = lib.mkForce false;

    # TODO: remove when not debugging:
    # isoImage.squashfsCompression = null;

    nixpkgs.hostPlatform.system = "x86_64-linux";

    networking.wireless.enable = lib.mkForce false;
    networking.wireless.iwd.enable = true;

    boot.loader.timeout = lib.mkOverride 10 10;
    documentation.enable = lib.mkOverride 10 false;
    documentation.info.enable = lib.mkOverride 10 false;
    documentation.man.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    services.fwupd.enable = lib.mkForce false;

    # BUG not sure if this works, at one point it was claimed it didn't...
    boot.initrd.systemd.enable = lib.mkForce false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}
