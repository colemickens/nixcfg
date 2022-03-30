#! /usr/bin/env nu

let cachix_cache = "colemickens"
let cachix_key = "abc"

let DIR="/home/cole/code/nixcfg" # TODO how to get this in nushell

let unstablepkgs = "https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz"
let buildargs = [
  --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org'
  --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso='
  --option 'build-cores' '0'
  --option 'narinfo-cache-negative-ttl' '0'
]
let srcdirs = [
  "nixpkgs/cmpkgs"  "home-manager/cmhm"  #"nixpkgs/master"
  "nixpkgs-wayland" "flake-firefox-nightly"
  "mobile-nixos"    "sops-nix"        "wip-pinebook-pro"
  "nixos-veloren"   #"nixos-azure"
]
let nixargs = [--experimental-features "nix-command flakes ca-references recursive-nix"]

# def log[] {
#   echo 
# }

def update[] {
  cd `{{DIR}}/pkgs`
  bash ./update.sh

  
}
