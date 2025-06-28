{ ... }:

# TODO: check with K900 but I don't think any of this is doing much for me:

{
  config = {
    programs = {
      rog-control-center.enable = true;
    };
    services = {
      asusd = {
        enable = true;
        enableUserService = true;
      };
    };
  };
}
