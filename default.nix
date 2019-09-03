let
  mkSystem = (import ./lib.nix {}).mkSystem;
in rec {
  xeep_sway__local = mkSystem rec {
    configFile = ./machines/xeep-sway.nix;
    nixpkgs = ../nixpkgs;
    rev = "git";
  };
  xeep_plasma__local = mkSystem rec {
    configFile = ./machines/xeep-plasma.nix;
    nixpkgs = ../nixpkgs;
    rev = "git";
  };
  xeep_gnome__local = mkSystem rec {
    configFile = ./machines/xeep-gnomeshell.nix;
    nixpkgs = ../nixpkgs;
    rev = "git";
  };

  xeep = [
    xeep_sway__local.config.system.build.toplevel
    xeep_gnome__local.config.system.build.toplevel
    xeep_plasma__local.config.system.build.toplevel
  ];
}
