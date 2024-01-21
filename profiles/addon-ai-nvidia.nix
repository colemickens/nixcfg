{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    inputs.nixified-ai.outputs.nixosModules.invokeai-nvidia
    # inputs.nixified-ai.outputs.nixosModules.textgen-nvidia
  ];

  config = {
    # services = {
    #   invokeai = {
    #     enable = true;
    #     settings = {
    #       host = "0.0.0.0";
    #       port = "9090";
    #     };
    #   };
    # };
    # networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 9090 ];
  };
}
