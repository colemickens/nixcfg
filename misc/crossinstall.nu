def main [] {
  nix build ".#toplevels.rockfiveb1"
  
  # bootfiles = "capture"
  # => nix-path-registration
  
}
