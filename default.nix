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
    configFile = ./machines/xeep-gnome.nix;
    nixpkgs = ../nixpkgs;
    rev = "git";
  };

  xeep_sway__cmpkgs = mkSystem rec {
    configFile = ./machines/xeep-sway.nix;
    nixpkgs = ./imports/nixpkgs/cmpkgs;
    rev = "git";
  };

  # TODO: if we omit "rev" from local path builds,
  # do we still get the git revision in the end?
  #
  # make ./imports/nixpkgs/foo/ include a default.nix plz
  # if we keep `.git` does it also get the rev properly?

  xeep = [
    xeep_sway__local.config.system.build.toplevel
    xeep_gnome__local.config.system.build.toplevel
    xeep_plasma__local.config.system.build.toplevel
  ];
}
