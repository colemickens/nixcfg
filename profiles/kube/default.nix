{ config, lib, pkgs, ... }:

let
in {
  imports = [
    ../../users/cole
    ../common
  ];

  networking.firewall.enable = false;

  # dev dependencies
  environment.systemPackages = with pkgs; [ mailcatcher ];

  virtualisation.containerd.enable = true;

  services = {
    #kubelet.enable = true;
    #kubernetes = {
    #  roles = [ "master" "node" ];
    #};

    # TODO: this should move to in-cluster.
    # bootstrap with cluster-admin + manifests
    redis = { enable = true; };
  };
}
