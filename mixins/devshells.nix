{ pkgs, config, inputs, ... }:

# include this to force devshells to be available on the machine
{
  config = {
    environment.systemPackages = [
      inputs.self.hydraBundles.${pkgs.system}.shells
    ];
  };
}
