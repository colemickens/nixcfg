{ pkgs, lib, config, inputs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
    ];
    networking.firewall = {
      allowPing = true;
      extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
    };
    # TODO: convert this to a samba pre-start script instead
    system.activationScripts = {
      sambaUserSetup = {
        text = ''
          PATH=$PATH:${lib.makeBinPath [ pkgs.samba ]}
          printf "cole\ncole\n" | pdbedit -a -u cole -t -b tdbsam:/var/lib/samba/private/passdb.tdb
        '';
        deps = [ ];
      };
    };
    
    # TODO: use systemd.tmpfiles for configuring the share dirs properly
    
    services.samba = {
      enable = true;
      enableNmbd = true;
      enableWinbindd = false;
      securityType = "user";
      openFirewall = true;

      # TODO: why can't I restrict to SMB4?
      extraConfig = ''
        # TODO: this Raven scanner needs SMB2
        # client min protocol SMB3_11
        # server min protocol = SMB3_11
        server smb encrypt = desired
        server multi channel support = yes
        deadtime = 30
        use sendfile = yes
        read raw = yes
        min receivefile size = 16384
        aio read size = 1
        aio write size = 1
        socket options = IPTOS_LOWDELAY TCP_NODELAY IPTOS_THROUGHPUT SO_RCVBUF=131072 SO_SNDBUF=131072
        max protocol
      '';

      shares = {
        # "cole" = {
        #   path = "/home/cole";
        #   browseable = "yes";
        #   "read only" = "yes";
        #   "guest ok" = "no";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "cole";
        #   "force group" = "cole";
        # };
        # "var" = {
        #   path = "/var/";
        #   browseable = "no";
        #   "read only" = "yes";
        #   "guest ok" = "no";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "cole";
        #   "force group" = "cole";
        # };
        # "rclone" = {
        #   path = "/mnt/rclone";
        #   browseable = "yes";
        #   "read only" = "yes";
        #   "guest ok" = "yes";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "cole";
        #   "force group" = "cole";
        # };
        "paperless-consume" = {
          path = "/var/lib/paperless/consume";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "cole";
          "force group" = "cole";
        };
      };
    };
    services.samba-wsdd = {
      enable = true;
    };
  };
}
