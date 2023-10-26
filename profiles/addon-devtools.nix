{ pkgs, config, inputs, ... }:

# these are dev tools that we want available
# system wide on my dev machine(s)

{
  config = {
    home-manager.users.cole = { pkgs, config, ... }@hm: {
      home.packages = with pkgs; [
        nil
      ];
    };
  };
}
