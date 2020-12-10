{ pkgs, config, inputs, ... }:
let
  email = "test.gcal.api@gmail.com";
  dir = "test_gcal_api__gmail_com";

  email2 = "cole.mickens@outlook.com";
  dir2 = "cole_mickens__outlook_com";
in {
  config = {
    sops.secrets."gmail-meli-client.json" = {
      owner = "cole";
      group = "cole";
    };

    # sops.secrets."gmail-meli-pw.txt" = {
    #   owner = "cole";
    #   group = "cole";
    # };

    home-manager.users.cole = { pkgs, ... }: {
      /*accounts.email.accounts = {
        "cole_mickens__outlook_com" = rec {
          address = "cole.mickens@outlook.com";
          userName = address;
          passwordCommand = "${pkgs.get-xoauth2-token}/bin/get-xoauth2-token --client-secret-path ${config.sops.secrets."meli-microsoft-client.json".path} --auth-method redirect --username '${address}'";
          imap = {
            host = "";
            port = "";
            tls = "";
          };
          smtp = {
            host = "";
            port = 13;
            tls = true;
          };
        };
        "test_gcal_api__gmail_com" = rec {
          address = "test.gcal.api@gmail.com";
          userName = address;
          passwordCommand = "${pkgs.get-xoauth2-token}/bin/get-xoauth2-token --client-secret-path ${config.sops.secrets."meli-google-client.json".path} --auth-method redirect --username '${address}'";
          imap = {
            host = "";
            port = "";
            tls = "";
          };
          smtp = {
            host = "smtp.gmail.com";
            port = 587;
            tls = true;
          };
        };
      };*/
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
              use_oauth2 = true;
              server_password_command = "${pkgs.get-xoauth2-token}/bin/get-xoauth2-token --client-secret-path ${config.sops.secrets."gmail-meli-client.json".path} --auth-method redirect --username '${email}'";
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
                  value = "${pkgs.get-xoauth2-token}/bin/get-xoauth2-token --client-secret-path ${config.sops.secrets."gmail-meli-client.json".path} --auth-method redirect --username '${email}'";
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