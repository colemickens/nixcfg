{ ... }:

{
  config = {
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    nix.autoOptimiseStore = true;
  };
}
