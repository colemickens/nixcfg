{ ... }:

let
  mkMachine = _nixpkgs: _nixoscfg: _system:
    let
      pkgs = import _nixpkgs {
        system = _system;
        inherit (machine.config.nixpkgs) config overlays;
      };
    
      machine = import "${_nixpkgs}/nixos/lib/eval-config.nix" {
        inherit (pkgs) system;
        inherit pkgs;
        modules = [ _nixoscfg ];
      };
    in
      machine.config.system.build.toplevel;

  result = {
    xeep = (mkMachine
      "/etc/nixpkgs-cmpkgs"
      "/etc/nixcfg/devices/xeep/default.nix"
      "x86_64-linux");

    # For now I don't care if we are on the actual latest
    # so going to hotlink the plex branch
    # when the plex fix is merged, we'll switch back to nixpkgs=cmpkgs anyway
    chimera = (mkMachine
      (builtins.fetchTarball "https://github.com/colemickens/nixpkgs/archive/plex.tar.gz")
      "/etc/nixcfg/devices/chimera/default.nix"
      "x86_64-linux");

    # TODO: not actually buildable when not on packet machine (/etc/nixos/packet/...)
    #packet-kube = (mkMachine
    #  "/etc/nixpkgs-kata3"
    #  "/etc/nixcfg/devices/packet-kube/configuration.nix"
    #  "x86_64-linux");
  };
in
  result

