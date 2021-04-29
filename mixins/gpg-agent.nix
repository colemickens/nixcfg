{ pkgs, ... }:

{
  config = {
    # try to enable gnupg's udev rules
    # to allow it to do ccid stuffs
    hardware.gpgSmartcards.enable = true;

    # this allows gpg to see yubikey/openpgp with ccid (I think, no pcscd anyway)
    #services.udev.packages = [ pkgs.yubikey-personalization ];
    #services.pcscd.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      # TODO: this needs to move to some sort of zsh init optiony thingy
      #home.sessionVariables = {
        #SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
      #};

      programs.gpg.enable = true;
      programs.gpg.package = pkgs.gnupg23;
      programs.gpg.scdaemonSettings = {
        #disable-ccid = true;
      };

      services.gpg-agent = {
        # this has the SAME problem as above^, or rather is the same thing!
        #enableSshSupport = true;

        enable = true;
        enableExtraSocket = true;
        defaultCacheTtl = 34560000;
        defaultCacheTtlSsh = 34560000;
        maxCacheTtl = 34560000;
        maxCacheTtlSsh = 34560000;
      };
    };
  };
}
