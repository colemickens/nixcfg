{ pkgs, ... }:

let
  ykDisconnect = pkgs.writeShellScript "yk-disconnect.sh" ''
    ${pkgs.systemd}/bin/loginctl lock-sessions
  '';
in
{
  config = {
    # auto-lock device on removal of ANY yubikey-looking USB device
    services.udev.extraRules = ''
      ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="1050/406/543", RUN+="${ykDisconnect} '%E{SEQNUM}'"
    '';

    # enable pam_u2f integration
    security.pam.u2f.enable = true;

    # enable the u2f keys for my user
    # (NOTE: "Yubico" is just a questionable default, apparently, see "authFile" option)
    home-manager.users.cole =
      let
        # `pam_u2f` (don't use -N, pam ends up burning fido retries and locking it out!)
        mapping_usba = "2SuopB53dlt3MXGqlC9s1bNu8QlLXWvP0vI50J34d9yyWHhckMF2wb44a3TBAtSuDJmlGEDica02Je6u+2DW1g==,96hoe48WSy6+CasvLxSvi4k0Cqbjf+68MJvO23RLJD9HgtoFlj8vcTPwkV/I664By8Rw07WT/Cj8j86CicyMUA==,es256,+presence";
        mapping_usbc = "Lzrc/jEJLZyBus5Cq8ufhtarA14RBs9WByxwhhWumK5lLOWu4kSn9ptkcJFlqbLldBUwMRV/JYzIKcXdPBXSaQ==,10K/2WFm1fb2ue9Bw2NxNIL2BRvab8TBYuM4J56yjo3bf1H8HB93580Ci4AY9QdaPEOK2LlqClG/exxF7L+02A==,es256,+presence";
      in
      (
        { pkgs, ... }:
        {
          xdg.configFile."Yubico/u2f_keys".text = ''
            cole:${mapping_usba}:${mapping_usbc}
          '';
        }
      );
  };
}
