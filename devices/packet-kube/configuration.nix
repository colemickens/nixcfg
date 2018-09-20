#!nix
{ config, lib, pkgs, ... }:

{
  imports = [
    /etc/nixos/packet.nix
    ../../users/cole
  ];

  networking.firewall.enable = false; #TODO: reenable (we were told how on the github pr)

  environment.systemPackages = with pkgs; [ cri-tools ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "18.03"; # Did you read the comment?

  boot.kernelPackages = pkgs.linuxPackages_4_18;
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs:
      { linux_4_18 = pkgs.linux_4_18.override {
          extraConfig =
            ''
              MLX5_CORE_EN y
            '';
        };
      };
    };
  };

  nix = {
    trustedBinaryCaches = [
      https://kixstorage.blob.core.windows.net/nixcache
      https://cache.nixos.org
      https://hydra.nixos.org
    ];
    binaryCachePublicKeys = [
      "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];
    nixPath = [
      "/etc/nixos"
      "nixpkgs=/etc/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
  };

  environment.noXlibs = true;
  virtualisation = {
    # it's weird about (docker-)runc, and it's not needed in general
    docker.enable = true;

    # the only CRI runtime available right now
    # TODO: this shouldbe set via kubelet's kubelet.containerRuntime = []; # TODO: it might already be?
    containerd.enable = true;
    # TODO:
    #containerd.runtimes = {
    #  "foo": {},
    #  "bar": {},
    #};

    # kata
    # TODO set this via the "containerd"/"crio" usage of the thing
    # TODO: should we be using application.kata-runtime.eanble instead since theres no service?
    kata-runtime.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    kubernetes = {
      roles = [ "master" "node" ];
      masterAddress = "apiserver.kix.cluster.lol";

      # TODO: implement/support
      # containerRuntime = "containerd";
      # untrustedRuntime = "kata";
      easyCerts = true;
      apiserver.extraSANs = [ "kix.cluster.lol" ];

      kubelet.extraOpts = "--fail-swap-on=false"; # TODO: add the container runtime flag(s)
    };
  };
}

