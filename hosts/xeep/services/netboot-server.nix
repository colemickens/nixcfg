{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  netbootServer = "192.168.1.10"; # TODO: de-dupe across netboot-client.nix?

  pimac = n: inputs.self.nixosConfigurations.${n}.config.system.build.sbc_mac;
  piser = n: inputs.self.nixosConfigurations.${n}.config.system.build.sbc_serial;
  piubi = n: inputs.self.nixosConfigurations.${n}.config.system.build.sbc_ubootid;

  # for each host, link in by the ... serial?
  tftp_netboots = pkgs.runCommand "tftp-netboots" { }
    (
      (
        builtins.foldl'
          (x: y: x + ''
            ln -s \
              "${inputs.self.netboots.${y}}" \
              "$out/${piser y}"
          '') ''
          set -x
          mkdir $out
        ''
          netbootHosts
      )
      +
      (
        builtins.foldl'
          (x: y: x + ''
            ln -s \
              "$out/${piser y}/extlinux/extlinux.conf" \
              "$out/pxelinux.cfg/${piubi y}"
          '') ''
          mkdir -p $out/pxelinux.cfg
        ''
          netbootHosts
      )
    );

  netbootHosts = builtins.attrNames (inputs.self.netboots);
  nfsfirmHosts = [ ];
  # nfsfirmHosts = builtins.attrNames (inputs.self.nfsfirms);
in
{
  config = {
    networking.firewall = {
      # nfs
      allowedUDPPorts = [ 67 68 69 4011 111 2049 4000 4001 4002 ];
      allowedTCPPorts = [ 67 69 4011 9000 111 2049 4000 4001 4002 ];
    };

    services.atftpd = {
      enable = true;
      extraOptions = [ "--verbose=7" ];
      root = tftp_netboots.outPath;
    };

    fileSystems =
      (
        {
          "/export/nix-store" = {
            device = "/nix/store";
            options = [ "bind" "ro" ];
          };
        }
        // (lib.mapAttrs'
          (hn: v: {
            name = "/export/hostdata/${hn}";
            value = {
              device = "/var/lib/nfs-hostdata/${hn}";
              options = [ "bind" ];
            };
          })
          (lib.genAttrs netbootHosts (hn: { })))
      );
    systemd.mounts = (
      (builtins.map
        (hn: rec {
          what = "${inputs.self.netboots.${hn}}/dbexport";
          where = "/export/nixdb/${hn}";
          type = "bind";
          description = where;
          options = "bind,ro";
          mountConfig = {
            ForceUnmount = true;
          };
        })
        netbootHosts)
      ++
      (builtins.map
        (hn: rec {
          what = "${inputs.self.nfsfirms.${hn}}";
          where = "/export/nfsfirms/${hn}";
          type = "bind";
          description = where;
          options = "bind,ro";
          mountConfig = {
            ForceUnmount = true;
          };
        })
        nfsfirmHosts)

    );
    systemd.automounts = (
      (builtins.map
        (hn: rec {
          where = "/export/nixdb/${hn}";
          description = where;
          wantedBy = [ "multi-user.target" ];
          restartTriggers = [
            inputs.self.netboots.${hn}
          ];
        })
        netbootHosts)
      ++
      (builtins.map
        (hn: rec {
          where = "/export/nfsfirms/${hn}";
          description = where;
          wantedBy = [ "multi-user.target" ];
          restartTriggers = [
            inputs.self.nfsfirms.${hn}
          ];
        })
        nfsfirmHosts)
    );

    # services.rpcbind.enable = true;
    services.nfs.server = {
      enable = true;
      # statdPort = 4000;
      # lockdPort = 4001;
      # mountdPort = 4002;
      createMountPoints = true; # even though it worked without this?
      hostName = "192.168.1.10";
      extraNfsdConfig = ''
        vers3=off
      '';
      exports = (
        ''
        '' +
        (
          # TODO: difference between /export/nixdb + /export/nixdb/${hn}?
          builtins.foldl'
            (def: hn: def + ''
              /export/hostdata/${hn}   192.168.0.0/16(rw,nohide,insecure,no_root_squash,no_subtree_check)
              /export/nixdb/${hn}      192.168.0.0/16(ro,nohide,insecure,no_root_squash,no_subtree_check)
              /export/nfsfirms/${hn}   192.168.0.0/16(ro,nohide,insecure,no_subtree_check)
            '') ''
            /export               192.168.0.0/16(fsid=0,ro,insecure,no_subtree_check)
            /export/nix-store     192.168.0.0/16(ro,nohide,insecure,no_subtree_check)
          ''
            netbootHosts
        )
        # // (builtins.mapAttrs' (n: v: (lib.nameValuePair
        #   "/export/toplevels/${n}"
        #   {
        #     device = tl n;
        #     options = [ "bind" ];
        #   }
        # ) netbootHosts))
        # // (builtins.mapAttrs' (n: v: (lib.nameValuePair
        #   "/export/hostdata/${n}"
        #   {
        #     device = "/var/lib/nfs-hostdata/${n}";
        #     options = [ "bind" ];
        #   }
        # ) netbootHosts))
      );
    };
  };
}
