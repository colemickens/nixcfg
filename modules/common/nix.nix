{ ... }:

let
  useLocal = true;
  over = name: url:
    if useLocal && builtins.pathExists "/etc/nix-overlays/${name}"
    then (import "/etc/nix-overlays/${name}")
    else (import (builtins.fetchTarball url));
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (over "nixpkgs-wayland" "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz")
      (over "nixpkgs-colemickens" "https://github.com/colemickens/nixpkgs-colemickens/archive/master.tar.gz")
      (over "azure-cli-nix" "https://github.com/stesie/azure-cli-nix/archive/21d92db4d81af549784c8545c40f7a1abdb9c7dd.tar.gz")
      (over "nixpkgs-mozilla" "https://github.com/mozilla/nixpkgs-mozilla/archive/0d64cf67dfac2ec74b2951a4ba0141bc3e5513e8.tar.gz")
    ];
  };

  nix = {
    nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];
    binaryCachePublicKeys = [
      "nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4="
      "nixpkgs-colemickens.cachix.org-1:mPLfhD5O77PMiEfiUy5rMHeIURcmvwQGevAms+bak9w="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
    binaryCaches = [
      "https://nixcache.cluster.lol"
      "https://cache.nixos.org"
      "https://colemickens.cachix.org"
      "https://nixpkgs-colemickens.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trustedUsers = [ "root" "@wheel" ];
  };
}

