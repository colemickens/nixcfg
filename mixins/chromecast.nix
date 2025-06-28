{ ... }:

{
  config = {
    networking.firewall.extraCommands = ''
      iptables -I INPUT -p udp -m udp --dport 32768:60999 -j ACCEPT
    '';
  };
}
