{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  pwdFile = "/foo/bar";
in
{
  imports = [
    # this make the azure go vroom
    inputs.nixos-azure.nixosModules.azure-image

    ../../profiles/interactive.nix
    ../../mixins/tailscale.nix

    inputs.nixos-mailserver.nixosModules.mailserver
  ];

  config = {
    virtualisation.azure.image.diskSize = 10000;
    system.stateVersion = "21.03";

    # tmpfiles for maildir (for zfs backup purposes)
    systemd.tmpfiles.rules = [
      "d '/run/state/ssh' - root - - -"

      # "d '/var/lib/tailscale' - root - - -"
      # "d '/run/state/tailscale' - root - - -"

      # "d '/run/state/plex' - plex - - -"
      # "d '/var/lib/plex' - plex - - -"
      
      # "d '/run/state/postgres' - postgres - - -"
      # "d '/var/lib/postgres' - postgres - - -"
      
      # "d '/run/state/hydra' - hydra - - -"
      # "d '/var/lib/hydra' - hydra - - -"
    ];

    # sshd keys come from persistent location (/run/state is bound to zfs vol)
    services.openssh = {
      enable = true;
      hostKeys = [
        { path = "/run/state/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
        { path = "/run/state/ssh/ssh_host_rsa_key";     type = "rsa"; }
      ];
    };

    nix.nixPath = [];
    nix.gc.automatic = false; # override for builder/devenv
    nix.nrBuildUsers = 128;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    # TODO: move to base azure image
    environment.systemPackages = with pkgs; [
      cryptsetup zfs
    ];

    mailserver = {
      enable = true;
      fqdn = "mail.r10e.tech";
      domains = [ "r10e.tech" ];
      loginAccounts."cole@r10e.tech" = {
        hashedPasswordFile = pwdFile;
        aliases = [ "postmaster@r10e.tech" ];
      };
      certificateScheme = 3;

      mailDirectory = "/var/vmail";
      dkimKeyDirectory = "/var/dkim";
    };
    security.acme.email = "cole.mickens@gmail.com";
    security.acme.acceptTerms = true;

    fileSystems = {
      "/" = {
        fsType = "ext4";
        autoResize = true;
      };
      # "/var/vmail" = {
      #   fsType = "zfs";
      #   device = "azmail/vmail";
      # }; 
      # "/var/dkim" = {
      #   fsType = "zfs";
      #   device = "azmail/dkim";
      # };
      # "/run/state" = {
      #   fsType = "zfs";
      #   device = "azpool/state";
      # };
    };

    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];

      growPartition = true;
      kernelPackages = pkgs.linuxPackages_latest;
    };

    networking = {
      hostId = "aaabbba0";
      hostName = "azmail";
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      useNetworkd = true;
      useDHCP = false;
      interfaces."eth0".useDHCP = true;
    };
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    systemd.network.enable = true;

    services.openssh.passwordAuthentication = false;
    security.sudo.wheelNeedsPassword = false;
  };
}
