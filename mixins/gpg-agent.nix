{ pkgs, ... }:

let
  def = {
    gnupgPkg = pkgs.gnupg23;
  };
  config1 = def // {
    enableGpgRules = true;
    enableYubikeyRules = false;
    enablePcscd = false;
    disableCcid = false;
  };
  config2 = def // {
    enableGpgRules = false;
    enableYubikeyRules = true;
    enablePcscd = false;
    disableCcid = false;
  };
  config3 = def // {
    enableGpgRules = false;
    enableYubikeyRules = false;
    enablePcscd = true;
    disableCcid = true;
  };
  config4 = config3 // {
    enableGpgRules = false;
    enableYubikeyRules = false;
    enablePcscd = true;
    disableCcid = false;
    gnupgPkg = pkgs.gnupg22; # old gpg falls back to pc/sc automatically
  };
  ult = def // {
    enableGpgRules = true;
    enableYubikeyRules = true;
    enablePcscd = true;
    disableCcid = true;
  };
  ecfg = ult;
in {
  config = {
    # okay yikes, since some of this is dependent on scdaemon
    # conf and state, let's make sure we reset (kill) scdaemon each time
    # system.activationScripts.step-gpg-reset = {
    #   text = ''
    #     ${pkgs.procps}/bin/pkill -9 scdaemon || true
    #   '';
    #   deps = [];
    # };
    # system.userActivationScripts.step-gpg-reset = {
    #   text = ''
    #     ${pkgs.systemd}/bin/systemctl --user stop gpg-agent || true
    #     ${pkgs.systemd}/bin/systemctl --user start gpg-agent || true
    #     ${pkgs.procps}/bin/pkill -9 gpg-agent || true
    #   '';
    #   deps = [];
    # };

    ######################

    # try to enable gnupg's udev rules
    # to allow it to do ccid stuffs
    hardware.gpgSmartcards.enable = ecfg.enableGpgRules;

    # we're using ledger->openpgp_xl as a smartcard
    hardware.ledger.enable = true;

    # TODO: Ledger Nano S/X require extra
    # udev/ccid rules?
    # see: "blue-app-openpgp-card.pdf" search: "0x2C97
    #services.udev.extraRules = ''
    #  #...
    #'';

    # this allows gpg to see yubikey/openpgp with ccid (I think, no pcscd anyway)
    services.udev.packages =
      if ecfg.enableYubikeyRules
      then [ pkgs.yubikey-personalization ]
      else [];

    # using this requires use of `disable-ccid` in scdaemon.conf!
    services.pcscd.enable = ecfg.enablePcscd;

    # bring pcsclite's polkit rules into the environment, I guess
    environment.systemPackages = if ecfg.enablePcscd then [ pkgs.pcsclite ] else [];

    # if all three are disable then shit just don't work
    # neither ccid or pc/sc are able to work

    home-manager.users.cole = { pkgs, ... }: {
      programs.gpg.enable = true;
      programs.gpg.package = ecfg.gnupgPkg;
      programs.gpg.scdaemonSettings =
        if ecfg.disableCcid
        then { disable-ccid = true; }
        else {};

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
