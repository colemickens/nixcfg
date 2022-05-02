{ config, pkgs, ... }:

{
  # settings are largely derived from:
  # https://github.com/nushell/nushell/blob/main/docs/sample_config/config.toml
  config = {
    home-manager.users.cole = { pkgs, ... }: {  
      xdg.configFile."nushell/env.nu".text = builtins.readFile ./nushell/env.nu;
      xdg.configFile."nushell/config.nu".source = ./nushell/config.nu;

      programs.nushell = {
        #enable = (pkgs.system == "x86_64-linux" || pkgs.system == "aarch64-linux");
        enable = true;
        # settings = {
        #   #### edit_mode = "vi";
        #   #### completion_mode = "circular";
        #   #### key_timeout = 10;

        #   filesize_format = "B"; # can be b, kb, kib, mb, mib, gb, gib, etc
        #   filesize_metric = true; # true => (KB, MB, GB), false => (KiB, MiB, GiB)
        #   skip_welcome_message = false; # Note to nushell developer: This is expected to be false, when testing nushell itself
        #   disable_table_indexes = false;
        #   nonzero_exit_errors = true;
        #   startup = [
        #     "alias la = ls --long"
        #     #"def nudown [] {fetch https://api.github.com/repos/nushell/nushell/releases | get assets | select name download_count}"
        #     "def nuver [] {version | pivot key value}"
        #   ];
        #   table_mode = "other"; # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        #   #plugin_dirs = ["D:\\Src\\GitHub\\nu-plugin-lib\\samples\\Nu.Plugin.Len\\bin\\Debug\\netcoreapp3.1"];
        #   pivot_mode = "auto"; # auto, always, never
        #   ctrlc_exit = false;
        #   complete_from_path = true;
        #   rm_always_trash = true;
        #   #prompt = "build-string (ansi gb) (pwd) (ansi reset) '(' (ansi cb) (do -i { git rev-parse --abbrev-ref HEAD } | str trim ) (ansi reset) ')' (char newline) (ansi yb) (date format '%m/%d/%Y %I:%M:%S%.3f %p') (ansi reset) '> ' ";

        #   color_config = {
        #     primitive_int = "green";
        #     primitive_decimal = "red";
        #     primitive_filesize = "ur";
        #     primitive_string = "pb";
        #     primitive_line = "yellow";
        #     primitive_columnpath = "cyan";
        #     primitive_pattern = "white";
        #     primitive_boolean = "green";
        #     primitive_date = "ru";
        #     primitive_duration = "blue";
        #     primitive_range = "purple";
        #     primitive_path = "yellow";
        #     primitive_binary = "cyan";
        #     separator_color = "purple";
        #     header_align = "l"; # left|l, right|r, center|c;
        #     header_color = "c"; # green|g, red|r, blue|u, black|b, yellow|y, purple|p, cyan|c, white|w;
        #     header_bold = true;
        #     index_color = "rd";
        #     leading_trailing_space_bg = "white";
        #   };

        #   line_editor = {
        #     max_history_size = 100000;
        #     history_duplicates = "ignoreconsecutive"; # alwaysadd,ignoreconsecutive
        #     history_ignore_space = false;
        #     completion_type = "circular"; # circular, list, fuzzy
        #     completion_prompt_limit = 100;
        #     keyseq_timeout_ms = 500; # ms
        #     edit_mode = "emacs"; # vi, emacs
        #     auto_add_history = true;
        #     bell_style = "audible"; # audible, none, visible
        #     color_mode = "enabled"; # enabled, forced, disabled
        #     tab_stop = 4;
        #   };

        #   textview = {
        #     term_width = "default"; # "default" or a number
        #     tab_width = 4;
        #     colored_output = true;
        #     true_color = true;
        #     header = true;
        #     line_numbers = true;
        #     grid = false;
        #     vcs_modification_markers = true;
        #     snip = true;
        #     wrapping_mode = "NoWrapping"; # Character, NoWrapping
        #     use_italics = true;
        #     paging_mode = "QuitIfOneScreen"; # Always, QuitIfOneScreen, Never
        #     pager = "less";
        #     theme = "TwoDark";
        #   };
        # };
      };
    };
  };
}
