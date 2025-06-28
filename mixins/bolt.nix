{ ... }:

{
  config = {
    # the module should do it
    #environment.systemPackages = with pkgs; [ bolt ];
    services.hardware.bolt.enable = true;
  };
}
