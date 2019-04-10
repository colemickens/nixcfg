{
  xeepSystem = import ./configurations/xeep.nix;
  #chimeraSystem = import ./configurations/chimera.nix;
  veraSystem = import ./configurations/vera.nix;

  #goonhabSystem = import ./configurations/goonhab.nix;
  
  # TODO: finish the USB installer
  #  grub with boot entries for each system
  #  with installer scripts that will auto install the point-in-time snapshot of nixcfg and the built corresponding clostures

  # allowing for maximum reproducibility by tracking a single repo and being able to reconsitute a fresh machine
  # at all time

  # in the future this could evolve to produce an automatic OS image for RPI netboot server, or whatever else really

  #totalInstall = import ./installer {
  #  machineConfigurations = [
  #    xeepSystem,
  #    chimeraSystem
  #  ];
  #};

  # netboot targets
}
