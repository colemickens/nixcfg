{ lib }:
with lib;

# TODO:
# 1. upstream this
# 2. upstream the hostkey change

buildMachines:
# copied from : https://github.com/NixOS/nixpkgs/blob/d600f006/nixos/modules/services/misc/nix-daemon.nix#L521
concatMapStrings (machine:
    "${if machine ? sshUser && machine.sshUser != null then "${machine.sshUser}@" else ""}${machine.hostName} "
    + (if machine.system != null then machine.system else concatStringsSep "," machine.systems)
    + " ${if machine ? sshKey && machine.sshKey != null then machine.sshKey else "-"} ${toString machine.maxJobs} "
    + toString (machine.speedFactor)
    + " "
    + concatStringsSep "," (machine.mandatoryFeatures ++ machine.supportedFeatures)
    + " "
    + concatStringsSep "," machine.mandatoryFeatures
    + (if (machine ? sshHostKeyBase64)
        then " " + concatStringsSep "," machine.sshHostKeyBase64
        else "")
    + "\n"
    ) buildMachines