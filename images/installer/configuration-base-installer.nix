{
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./configuration-base.nix
  ];

  config = {
    # TODO: remove when not debugging:
    # isoImage.squashfsCompression = null;

    ## <tailscale auto-login>
    services.tailscale = {
      enable = true;
      extraDaemonFlags = [ "--state=mem:" ];
    };
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        if curl --max-time 10 'https://tailscale.com'; then
          echo "trying to connect to tailscale" &>2
          sudo tailscale login --qr
        else
          echo "no internet connection, skipping tailscale qr login" &>2
        fi
      )
    '';
    services.getty.autologinUser = lib.mkForce "cole";
    ## </tailscale auto-login>

    boot.loader.timeout = lib.mkOverride 10 10;

    ## my custom installer utils
    environment.systemPackages = (
      with pkgs;
      [
        sbctl
        # bcachefs-tools
      ]
    );
  };
}
