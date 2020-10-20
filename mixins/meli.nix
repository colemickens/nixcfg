{ pkgs, config, inputs, ... }:
let
  email = "test.gcal.api@gmail.com";
  dir = "test_gcal_api__gmail_com";
in {
  config = {
    sops.secrets."gmail-meli-pw.txt" = {
      owner = "cole";
      group = "cole";
    };

    home-manager.users.cole = { pkgs, ... }: {
      programs.meli = {
        enable = true;
        settings = {
          accounts = {
            "${dir}" = {
              identity = "${email}";
              format = "imap";
              server_hostname = "imap.gmail.com";
              server_port = 993;
              use_starttls = false; # gmail expects false
              server_username = "${email}";
              server_password_command = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."gmail-meli-pw.txt".path}";
              root_mailbox = "$HOME/.local/share/meli/${dir}";
            };
          };
          composing = {
            send_mail = {
              hostname = "smtp.gmail.com";
              port = 587;
              security = { type = "STARTTLS"; };
              auth = {
                type = "auto";
                username = "${email}";
                password = {
                  type = "command_eval";
                  value = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."gmail-meli-pw.txt".path}";
                };
              };
            };
            editor_command = "\${EDITOR} +/^$";
          };
          pager = {
            filter = "COLUMNS=72 ${pkgs.python3Packages.pygments}/bin/pygmentize -l email";
            html_filter = "${pkgs.w3m}/bin/w3m -I utf-8 -T text/html";
          };
          notifications = {
            script = "${pkgs.libnotify}/bin/notify-send";
          };
          shortcuts = {
            composing.edit_mail = "e";
            listing.new_mail = "m";
            listing.set_seen = "m";
          };
          terminal.theme = "dark";
        };
      };
    };
  };
}