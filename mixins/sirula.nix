{
  pkgs,
  config,
  inputs,
  ...
}:

let
  tomlFormat = pkgs.formats.toml { };
  gen = cfg: (tomlFormat.generate "jj-config.toml" cfg);
in
{
  config = {
    nixpkgs.overlays = [
      (
        final: prev:
        let
          nwPkgs = inputs.nixpkgs-wayland.packages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          inherit (nwPkgs) sirula;
        }
      )
    ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        xdg.configFile."sirula/style.css".text = ''
          * {
            font-family: "Iosevka";        
            /*
              font-family: "OpenSans";
            */
          }
          .app-row {
              transition: unset;
              padding: 5px 0 5px 10px;
              background-color: #263238;
          }

          .app-row:selected {
                background-color: #37474F;
          }

          .app-label {
              margin-left: 10px;
              font-family: "Open Sans";
              font-size: 0.75em;
              font-weight: 300;
          }

          .app-list {
                background-color: #f00;
           }

          #root-box {
              border: 3px solid #263238;
              border-radius: 5px 5px 5px 5px;
              box-shadow: 0 19px 38px rgba(0,0,0,0.30), 0 15px 12px rgba(0,0,0,0.22);
              margin: 100px;
              background-color: #263238;
              font-size: 2em;
              font-weight: bold;
          }

          #search {
              font-size: 0.75em;
              font-weight: bold;
              padding: 2px 8px;
              margin: 5px;
          }
        '';
        xdg.configFile."sirula/config.toml".source = (
          gen {
            markup_highlight = "underline='low' weight='bold'";
            #markup_extra = "foreground='blue'";
            #markup_default = "foreground='yellow'";
            exclusive = true;
            lines = 1;
            icon_size = 64;
            anchor_left = false;
            anchor_right = false;
            anchor_top = false;
            anchor_bottom = false;
            margin_top = 1;
            margin_bottom = 0;
            margin_left = 0;
            margin_right = 0;
            width = 1000;
            height = 500;
          }
        );
      };
  };
}
