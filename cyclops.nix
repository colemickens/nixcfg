{
  # .output/{build-run-id?}/flake.lock
  inputsMeta = {
    cmpkgs = {
      base.url = "https://github.com/nixos/nixpkgs";
      base.branch = "nixos-unstable";
      origin.url = "git@github.com:colemickens/nixpkgs";
      oriign.branch = "cmpkgs";
    };
    home-manager = {
      base = {
        url = "https://github.com/nix-community/home-manager";
        branch = "master";
      };
      origin = {
        url = "git@github.com:colemickens/home-manager";
        branch = "cmpkgs";
      };
    };
  };
}
