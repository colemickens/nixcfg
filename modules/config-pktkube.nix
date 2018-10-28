#!nix
{ config, lib, pkgs, ... }:

let
  _imports = [
    ./common
  ] ++ (
    if lib.pathExists /etc/nixos/packet.nix
    then [ /etc/nixos/packet.nix ]
    else [ ./packet ]);
in
{
  imports = _imports;

  networking.firewall.enable = false; #TODO: reenable (we were told how on the github pr)

  environment.systemPackages = with pkgs; [
    cri-tools bind kata-agent
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "18.03"; # Did you read the comment?

  boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs:
      { linux_latest = pkgs.linux_latest.override {
          extraConfig =
            ''
              MLX5_CORE_EN y
            '';
        };
      };
    };
  };

  # NOTE: leave this here for when we remove it having any
  # dependencies on our own nixcfg modules
  nix = {
    binaryCaches = [ https://nixcache.cluster.lol https://cache.nixos.org ];
    trustedBinaryCaches = [ https://nixcache.cluster.lol https://cache.nixos.org ];
    binaryCachePublicKeys = [
      "nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
    kata-agent.enable = true;
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

