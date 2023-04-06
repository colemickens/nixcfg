{ pkgs, config, inputs, modulesPath, ... }:

{
  imports = [
    ../oci-common.nix

    ./kexec.nix
    ./justdoit.nix
    #./justdoit-auto.nix

    ../../../profiles/user-cole.nix
    ../../../mixins/sshd.nix
  ];

  config = {
    networking.hostName = "oracular_kexec";

    kexec.justdoit = {
      toplevel = builtins.unsafeDiscardStringContext inputs.self.toplevels.oracular.outPath;
    };
  };
}
