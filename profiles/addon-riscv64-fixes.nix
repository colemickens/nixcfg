{ pkgs, ... }:

{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        bcachefs-tools = prev.bcachefs-tools.overrideAttrs(old: {
          meta.broken = true;
        });
      })
    ];

    boot.bcachefs.package = null;
  };
}
