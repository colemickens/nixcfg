{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {  
      programs.nushell = {
        enable = (pkgs.system == "x86_64-linux" || pkgs.system == "aarch64-linux");

        settings = pkgs.lib.mkMerge [
          {
            edit_mode = "vi";
            startup = [ "alias ll [] { ls -l }" ];
            completion_mode = "circular";
            key_timeout = 10;
          }

          {
            startup = [ "alias e [msg] { echo $msg }" ];
            no_auto_pivot = true;
          }

          {
            color_config = {
              primitive_int = "green";
              primitive_decimal = "red";
              primitive_filesize = "ur";
              primitive_string = "pb";
              primitive_line = "yellow";
              primitive_columnpath = "cyan";
              primitive_pattern = "white";
              primitive_boolean = "green";
              primitive_date = "ru";
              primitive_duration = "blue";
              primitive_range = "purple";
              primitive_path = "yellow";
              primitive_binary = "cyan";
              separator_color = "purple";
              header_align = "l"; # left|l, right|r, center|c;
              header_color = "c"; # green|g, red|r, blue|u, black|b, yellow|y, purple|p, cyan|c, white|w;
              header_bold = true;
              index_color = "rd";
              leading_trailing_space_bg = "white";
            };
          }
        ];
      };
    };
  };
}
