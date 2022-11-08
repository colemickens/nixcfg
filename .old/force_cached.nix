{ coreutils }:

attrs:
with builtins;
let
  # Copied from <nixpkgs/lib>
  isDerivation = x: isAttrs x && x ? type && x.type == "derivation";

  # Return true if `nix-build` would traverse that attribute set to look for
  # more derivations to build.
  hasRecurseIntoAttrs = x: isAttrs x && (x.recurseForDerivations or false);

  # Wraps derivations that disallow substitutes so that they can be cached.
  toCachedDrv = drv:
    if !(drv.allowSubstitutes or true) then
      derivation
        {
          name = "${drv.name}-to-cached";
          system = drv.system;
          builder = "/bin/sh";
          args = [ "-c" "${coreutils}/bin/ln -s ${drv} $out; exit 0" ];
        }
    else
      drv;

  op = _: val:
    if isDerivation val then
      toCachedDrv val
    else if hasRecurseIntoAttrs val then
      forceCached val
    else
      val
  ;

  # Traverses a tree of derivation and wrap all of those that disallow
  # substitutes.
  forceCached = attrs: mapAttrs op attrs;
in
forceCached attrs