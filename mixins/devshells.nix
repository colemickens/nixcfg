{ pkgs, config, inputs, ... }:

# include this to force devshells to be available on the machine
# TODO: de-dupe this with devtools / shells / common-list to include somewhere/how
{
  config = {
    environment.systemPackages = [
      inputs.self.bundles.${pkgs.system}.devShells
    ];
  };
}
