{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        enableExtraSocket = true;
        defaultCacheTtl = 34560000;
        defaultCacheTtlSsh = 34560000;
      };
    };
  };
}
