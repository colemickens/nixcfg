{ pkgs, inputs, ... }:

let
  fmt = pkgs.formats.yaml { };
  gen = cfg: (fmt.generate "gopass-config.yml" cfg);
  
  gopassPkg = pkgs.gopass;
  # gopassPkg = inputs.stable.outputs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.gopass;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        gopassPkg
      ];

      xdg.configFile."gopass/config".text = ''
        [core]
        autosync = false
        nopager = true

        [generate]
        length = 14
        symbols = true

        [mounts]
        path = ~/.local/share/password-store

        [updater]
        check = false
      '';
      # source = gen {
      #   root = {
      #     askformore = false;
      #     autoclip = false;
      #     autoimport = true;
      #     autosync = true;
      #     check_recipient_hash = false;
      #     concurrency = 1;
      #     editrecipients = false;
      #     nocolor = false;
      #     nopager = true;
      #     notifications = true;
      #     safecontent = false;
      #     usesymbols = false;
      #     path = "gpgcli-gitcli-fs+file:///home/cole/.local/share/password-store";
      #     recipient_hash.".gpg-id" = "3078393735383037384445353330383330380aa69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26";
      #   };
      # };
    };
  };
}
