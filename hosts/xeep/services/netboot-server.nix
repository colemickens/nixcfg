{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  internalVhost = {
    useACMEHost = "cleo.cat";
    forceSSL = true;
    extraConfig = ''
      allow 100.0.0.0/8;
      allow 192.168.0.0/16;
      allow fd7a:115c:a1e0:ab12:0000:0000:0000:0000/64;
      deny all;
    '';
  };

  netbootServer = "192.168.1.10"; # TODO: de-dupe across netboot-client.nix?

  pimac = n: inputs.self.nixosConfigurations.${n}.config.system.build.pi_mac;
  piser = n: inputs.self.nixosConfigurations.${n}.config.system.build.pi_serial;
  piubi = n: inputs.self.nixosConfigurations.${n}.config.system.build.pi_ubootid;

  # for each host, link in by the ... serial?
  tftp_netboots = pkgs.runCommandNoCC "tftp-netboots" { }
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

    fileSystems = ({
      "/export/nix-store" = {
        device = "/nix/store";
        options = [ "bind" "ro" ];
      };
      "/export/nix-var-nix-shared" = {
        device = "/nix/var/nix/shared";
        options = [ "bind" "ro" ];
      };
    }
    // (lib.mapAttrs'
      (n: v: {
        name = "/export/hostdata/${n}";
        value = {
          device = "/var/lib/nfs-hostdata/${n}";
          options = [ "bind" ];
        };
      })
      (lib.genAttrs netbootHosts (n: { }))));

    systemd.timers."nix-dump-db" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nix-db-export.service" ];
      timerConfig.OnCalendar = "*:0/5";
    };
    systemd.services."nix-dump-db" = {
      wantedBy = [ "multi-user.target" ]; 
      #after = [ "network.target" ];
      description = "Make regular exports of the nix database.";
      # TODO: let systemd let this see /nix ?
      serviceConfig = {
        Type = "simple";
        ExecStart = (pkgs.writeScript "dump-db.sh" ''
          #!${pkgs.bash}/bin/bash
          set -x
          set -euo pipefail

          dest="/nix/var/nix/shared"
          mkdir -p "''${dest}"
          time ${config.nix.package}/bin/nix-store --dump-db > $dest/dump_new

          chmod -wx $dest/dump_new
          chmod +r $dest/dump_new
          mv \
            $dest/dump_new \
            $dest/dump
        '');
      };
    };

    services.nfs.server = {
      enable = true;
      statdPort = 4000;
      lockdPort = 4001;
      mountdPort = 4002;
      extraNfsdConfig = ''
        udp=y
      '';
      exports = (
        ''
        '' +
        (
          builtins.foldl'
            (x: y: x + ''
              /export/hostdata/${y}     192.168.1.0/16(rw,nohide,insecure,no_root_squash,no_subtree_check)
            '') ''
            /export                     192.168.1.0/16(fsid=0,ro,insecure,no_subtree_check)
            /export/nix-store           192.168.1.0/16(ro,nohide,insecure,no_subtree_check)
            /export/nix-var-nix-shared  192.168.1.0/16(ro,nohide,insecure,no_subtree_check)
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
