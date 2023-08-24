{ config, pkgs, ... }:

{
  config = {
    # TODO: why is this not blocked by allowAliases = false ???

    # services.paperless-ng = {
    networking.firewall.allowedTCPPorts = [ config.services.paperless.port ];
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = 58080;
      extraConfig = {
        # PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
        PAPERLESS_ADMIN_USER = "cole";
        PAPERLESS_ADMIN_PASSWORD = "cole";
      };
    };
    systemd.services.paperless-scheduler.after = [ "var-lib-paperless.mount" ];
    systemd.services.paperless-consumer.after = [ "var-lib-paperless.mount" ];
    systemd.services.paperless-web.after = [ "var-lib-paperless.mount" ];
  };
}
