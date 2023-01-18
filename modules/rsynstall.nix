{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

{
  config = {
    system.build.installFiles = (
      let
        closureInfo = pkgs.closureInfo { rootPaths = config.system.build.toplevel; };
      in
      pkgs.runCommand "installFiles-${config.networking.hostName}" { } ''
        set -x
        mkdir $out
        mkdir $out/boot
        mkdir $out/root
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
          -d $out/boot/ -c "${config.system.build.toplevel}"
      
        cp -a "${closureInfo}/registration" "$out/root/nix-path-registration"
        echo "${config.system.build.toplevel.outPath}" > "$out/root/toplevel"
      ''
    ).out;
    boot.postBootCommands = ''
      if [[ -f /nix-path-registration ]]; then
        ${config.nix.package}/bin/nix-store --load-db < /nix-path-registration

        touch /etc/NIXOS
        ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
        
        rm -f /nix-path-registration
      fi
    '';
  };
}
