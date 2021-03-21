{ lib }:
with lib;

# modified from https://github.com/NixOS/nixpkgs/blob/d600f006/nixos/modules/services/misc/nix-daemon.nix#L521

# TODO:
# 1. upstream this
# 2. upstream the hostkey change

buildMachines: machine:
  let
    machine = if machine ? sshUser && machine.sshUser != null
        then "${machine.sshUser}@${machine.hostName}"
        else machine.hostName;
    # (2) comma-separated list of platform identifiers
    systems = if machine.system != null then machine.system else concatStringsSep "," machine.systems;
    # (3) ssh identity file
    sshIdentityFile = if machine ? sshKey && machine.sshKey != null then machine.sshKey else "-";
    # (4) maximum number of nix builds
    maxBuilds = if machine ? maxBuilds then machine.maxBuilds else "-";
    # (5) speed factor
    speedFactor = if machine ? speedFactor then toString machine.speedFactor else "-";
    # (6) comma-separated list of supported features
    supportedFeatures = if machine ? supportedFeatures && supportedFeatures != [] && supportedFeatures != null
      then concatStringsSep "," (machine.mandatoryFeatures ++ machine.supportedFeatures) else "-";
    # (7) comma-separated list of mandatory features
    mandatoryFeatures = if machine ? mandatoryFeatures && mandatoryFeatures != [] && mandatoryFeatures != null
      then concatStringsSep "," machine.mandatoryFeatures else "-";
    # (8) base64 encoded ssh host key
    sshHostKeyBase64 = if machine ? sshHostKeyBase64 then machine.sshHostKeyBase64 else "-";
  in
    "${machine} ${systems} ${sshIdentityFile} ${maxBuilds} ${speedFactor} ${supportedFeatures} ${mandatoryFeautures} ${sshHostKeyBase64}"
