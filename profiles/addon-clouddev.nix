{ pkgs, config, inputs, ... }:

# these are dev tools that we want available
# system wide on my dev machine(s)

{
  config = {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
      3000
    ];
    environment.systemPackages = with pkgs; [
      openvscode-server
      # code-server # TODO: seems broken
    ];
    services = {
      # openvscode-server = {
      #   enable = true;
      #   user = "cole";
      #   group = "cole";
      #   host = "0.0.0.0"; # firewall protects us, we only allow in tailscale0
      #   port = 7777;
      #   extraEnvironment = {
      #     NIX_PATH = "nixpkgs=/home/cole/code/nixpkgs/cmpkgs";
      #   };
      # };
    };
  };
}
