{ lib }:
with lib;

# modified from https://github.com/NixOS/nixpkgs/blob/d600f006/nixos/modules/services/misc/nix-daemon.nix#L521
# TODO: upstream this?

let
  renderMachineLine = machine:
    let
      host = if machine ? sshUser && machine.sshUser != null
          then "${machine.sshUser}@${machine.hostName}"
          else machine.hostName;
      # (2) comma-separated list of platform identifiers
      sys = if machine.system != null then machine.system else concatStringsSep "," machine.systems;
      # (3) ssh identity file
      ident = if machine ? sshKey && machine.sshKey != null then machine.sshKey else "-";
      # (4) maximum number of jobs
      mj = if machine ? maxJobs then machine.maxJobs else "auto";
      # (5) speed factor
      sf = if machine ? speedFactor then toString machine.speedFactor else "1";
      # (6) comma-separated list of supported features
      sfeatures = if machine ? supportedFeatures && machine.supportedFeatures != [] && machine.supportedFeatures != null
        then concatStringsSep "," (machine.mandatoryFeatures ++ machine.supportedFeatures) else "-";
      # (7) comma-separated list of mandatory features
      mfeatures = if machine ? mandatoryFeatures && machine.mandatoryFeatures != [] && machine.mandatoryFeatures != null
        then concatStringsSep "," machine.mandatoryFeatures else "-";
      # (8) base64 encoded ssh host key
      sshHostKeyBase64 = if machine ? sshHostKeyBase64 then machine.sshHostKeyBase64 else "-";
    in
      "${host} ${sys} ${ident} ${mj} ${sf} ${sfeatures} ${mfeatures} ${sshHostKeyBase64}\n";
in
machines:
  concatMapStrings renderMachineLine machines
