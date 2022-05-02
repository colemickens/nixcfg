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
    services.samba = {
      enable = true;
      enableNmbd = true;
      enableWinbindd = false;
      securityType = "user";
      openFirewall = true;

      # TODO: why can't I restrict to SMB4?
      extraConfig = ''
        client min protocol SMB3_11
      '';

      shares = {
        "cole" = {
          path = "/home/cole";
          browseable = "yes";
          "read only" = "yes";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "cole";
          "force group" = "cole";
        };
        "rclone" = {
          path = "/mnt/rclone";
          browseable = "yes";
          "read only" = "yes";
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
