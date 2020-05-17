{ pkgs, ... }:

{
  enable = true;
  functions = {
    "gpgssh".body = ''
      set remote (ssh "{$@}" gpgconf --list-dir agent-agent-socket)
      set  local (ssh "{$@}" gpgconf --list-dir agent-socket)
      ssh -A -o "RemoteForward {$remote}:{$local}" -o StreamLocalBindUnlink=yes {$argv}
    '';
    "rdp".body = ''
      set RDPUSER "cole.mickens@gmail.com"
      set RDPPASS (gopass show -o "websites/microsoft.com/cole.mickens@gmail.com")
      set RDPHOST {$RDPHOST:-"192.168.1.11"}
      echo wlfreerdp /p:{$RDPPASS}/u:{$RDPUSER} /v:{$RDPHOST} /rfx +fonts /dynamic-resolution /compression-level:2
      wlfreerdp /p:{$RDPPASS} /u:{$RDPUSER} /v:{$RDPHOST} /rfx +fonts /dynamic-resolution /compression-level:2
    '';
    "megadl".body = ''
      set u "(gopass show johndough/mega | rg username | cut -d' ' -f2)"
      set p "(gopass show johndough/mega | rg password | cut -d' ' -f2)"
      echo megadl --username {$u} --password {$p} {$argv}
      megadl --username {$u} --password {$p} {$argv}
    '';
  };
}
