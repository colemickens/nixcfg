{ ... }:
{
  nix = {
    buildCores = 0;
    binaryCachePublicKeys = [
      "nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4="
      "nixpkgs-colemickens.cachix.org-1:mPLfhD5O77PMiEfiUy5rMHeIURcmvwQGevAms+bak9w="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nixpkgs-kubernetes.cachix.org-1:FtZMc4acxfHbDZBkWcOJ86Cji2bT6z8mx90gcS/72FQ="
    ];
    binaryCaches = [
      #"https://nixcache.cluster.lol"
      "https://cache.nixos.org"
      "https://colemickens.cachix.org"          # my system builds
      "https://nixpkgs-colemickens.cachix.org"  # my personal overlay
      "https://nixpkgs-wayland.cachix.org"      # my overlay with wayland stuff
      "https://nixpkgs-kubernetes.cachix.org"   # my overlay with kubernetes stuff
    ];
  };
}

