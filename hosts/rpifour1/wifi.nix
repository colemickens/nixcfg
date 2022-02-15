{ config, ... }:

{
  config = {
    networking = {
      wireless.networks."chimera-iot".pskRaw
        = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
    };
  };
}
