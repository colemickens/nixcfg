# https://git.xirion.net/0x76/nixos-configs/src/commit/3a9f7eefe2636b2e6cc0aecfd9b64eeac5d41266/common/services/flood.nix

{ config, pkgs, lib, ... }:
with lib;
let cfg = config.services.flood;
in
{
  options.services.flood = {
    enable = mkEnableOption "flood";

    user = mkOption {
      default = "flood";
      type = types.str;
      description = ''
        User account under which flood runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "rtorrent";
      description = ''
        Group under which flood runs.
        Flood needs to have the correct permissions if accessing rtorrent through the socket.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.flood;
      defaultText = "pkgs.flood";
      description = ''
        The flood package to use.
      '';
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = ''
        Address flood binds to.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = ''
        The flood web port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the port in <option>services.flood.port</option>.
      '';
    };

    rpcSocket = mkOption {
      type = types.str;
      readOnly = true;
      default = "/run/rtorrent/rpc.sock";
      description = ''
        RPC socket path.
        (Only used when auth=none).
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/flood";
      description = ''
        The directory where flood stores its data files.
      '';
    };

    downloadDir = mkOption {
      type = types.str;
      default = "/var/lib/rtorrent/download";
      description = ''
        Root directory for downloaded files.
      '';
    };

    authMode = mkOption {
      type = types.str;
      default = "none";
      description = ''
        Access control and user management method.
        Either 'default' or 'none'.
      '';
    };

    ssl = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable SSL. 
        key.pem and fullchain.pem needed in runtime directory.
      '';
    };

    baseURI = mkOption {
      type = types.str;
      default = "/";
      description = ''
        This URI will prefix all of Flood's HTTP requests
      '';
    };
  };

  config = mkIf cfg.enable {
    # Create group if set to default
    users.groups = mkIf (cfg.group == "rtorrent") {
      rtorrent = { };
    };

    # Create user if set to default
    users.users = mkIf (cfg.user == "flood") {
      flood = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        home = cfg.dataDir;
        description = "flood Daemon user";
        isSystemUser = true;
      };
    };

    # Open firewall if option is set to do so.
    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall) [ cfg.port ];

    # The actual service
    systemd.services.flood = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "flood system service";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Type = "simple";
        Restart = "on-failure";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/flood --baseuri ${cfg.baseURI} --rundir ${cfg.dataDir} --host ${cfg.host} --port ${toString cfg.port} ${if cfg.ssl then "--ssl" else ""} --auth ${cfg.authMode}  --rtsocket ${cfg.rpcSocket} --allowedpath ${cfg.downloadDir}";
      };
    };

    # This is needed to create the dataDir with the correct permissions.
    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0755 ${cfg.user} ${cfg.group} -" ];
  };
}
