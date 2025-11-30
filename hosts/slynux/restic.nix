{ pkgs, inputs, ... }:

{
  config = {
    users = {
      users.restic = {
        group = "restic";
        isSystemUser = true;
      };
      groups.restic = {};
    };

    security.wrappers.restic = {
      source = lib.getExe pkgs.restic;
      owner = "restic";
      group = "restic";
      permissions = "500"; # or u=rx,g=,o=
      capabilities = "cap_dac_read_search+ep";
    };

    services.restic.backups."backup-vaultwarden" = {
      user = "restic";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      repository = "azure:restic:/";
      package = pkgs.writeShellScriptBin "restic" ''
        exec /run/wrappers/bin/restic "$@"
      '';
      environmentFile = config.sops."azure-cmvwbackups-restic-env";
      passwordFile = config.sops."azure-cmvwbackups-restic-password";
      paths = [ "/var/lib/bitwarden_rs" ];
    };
  };
}
